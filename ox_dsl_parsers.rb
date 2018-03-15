require 'dsl_parsers'

module OxDslParsers
  class Address
    include DslParsers::OxXmlParser
    has_one :city, "City"
    has_one :state, "State"
    has_one :zip, "ZIP", Integer
    has_one :street, "Street"
  end
  class Item
    include DslParsers::OxXmlParser
    has_one :descr, "Description"
    has_one :quantity, "Quantity", Integer
    has_one :unit_price, "UnitPrice", Float
    has_one :reference, "@reference"
    def after_parse(r); r[:total_price] = r[:quantity] * r[:unit_price]; r; end
  end
  class Signature
    include DslParsers::OxXmlParser
    has_one :name, "Name"
    has_one :position, "Position"
    def after_parse(r); r[:position] ||= 'Some Employee'; r; end
  end
  class Client
    include DslParsers::OxXmlParser
    has_one :name, "Name"
    has_one :home_address, "Address", Address # cannot do where, ommitted, use hass_many and after parse if needed
  end
  class Order
    include DslParsers::OxXmlParser
    has_one :reference, "@reference"
    has_one :client, "Client", Client
    has_many :items, "Item", Item
    has_many :signatures, "Signed-By/Signature", Signature
    def after_parse(r)
      r[:total_price] = r[:items].map { |i| i.delete(:total_price) } .inject(0) { |x,y| x + y }
      r[:items] = r[:items].index_by { |i| i.delete(:reference) }
      r
    end
  end

  def self.parse(xml)
    OxDslParsers::Order.parse(xml)
  end
end

