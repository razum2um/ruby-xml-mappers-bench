mapping = File.expand_path('../xml-mapping/lib', __FILE__)
$LOAD_PATH.unshift mapping
require 'xml/mapping'

module XmlMapping
  class Address
    include XML::Mapping
    text_node :city, "City"
    text_node :state, "State"
    numeric_node :zip, "ZIP"
    text_node :street, "Street"
  end
  class Item
    include XML::Mapping
    text_node :descr, "Description"
    numeric_node :quantity, "Quantity"
    numeric_node :unit_price, "UnitPrice"
    def total_price
      quantity*unit_price
    end
  end
  class Signature
    include XML::Mapping
    text_node :name, "Name"
    text_node :position, "Position", :default_value=>"Some Employee"
  end
  class Client
    include XML::Mapping
    text_node :name, "Name"
    object_node :home_address, "Address", :class=>Address
  end
  class Order
    include XML::Mapping
    text_node :reference, "@reference"
    object_node :client, "Client", :class=>Client
    hash_node :items, "Item", "@reference", :class=>Item
    array_node :signatures, "Signed-By", "Signature", :class=>Signature, :default_value=>[]
    def total_price
      items.values.map{|i| i.total_price}.inject(0){|x,y|x+y}
    end
  end

  def self.parse(xml)
    XmlMapping::Order.load_from_xml(REXML::Document.new(xml).root)
  end
end

