mapping = File.expand_path('../xml-mapping/lib', __FILE__)
$LOAD_PATH.unshift mapping
require 'xml/mapping'

require 'bundler'
Bundler.load
require 'dsl_parsers'
require 'pry-byebug'
require 'rspec'
require 'benchmark/ips'

XMLFILE = File.read(File.expand_path('../xml/order.xml', __FILE__)).freeze

module XMLMappingExample
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
end

def parse_xml_mapping
  XMLMappingExample::Order.load_from_xml(REXML::Document.new(XMLFILE).root)
end

module DslParsersExample
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
end

def parse_dsl_parsers
  DslParsersExample::Order.parse(XMLFILE)
end

###

RESULT = {
  :reference=>"12343-AHSHE-314159",
  :client=>{:name=>"Jean Smith",
            :home_address=>{:city=>"San Mateo",
                            :state=>"CA",
                            :zip=>94403,
                            :street=>"2000, Alameda de las Pulgas"}},
  :items=>
    {"RF-0001"=>{:descr=>"Stuffed Penguin", :quantity=>10, :unit_price=>8.95},
     "RF-0034"=>{:descr=>"Chocolate", :quantity=>5, :unit_price=>28.5},
     "RF-3341"=>{:descr=>"Cookie", :quantity=>30, :unit_price=>0.85}},
  :signatures=>[{:name=>"John Doe", :position=>"product manager"},
                {:name=>"Jill Smith", :position=>"clerk"},
                {:name=>"Miles O'Brien", :position=>"Some Employee"}],
  :total_price=>257.5}

Suite = RSpec.describe 'results' do
  describe 'dsl-mapping' do
    subject { parse_dsl_parsers }
    it 'parses order' do
      expect(subject).to eq RESULT
    end
  end

  describe 'xml-mapping' do
    subject { parse_xml_mapping }
    it 'parses order attrs' do
      expect(subject.reference).to eq RESULT[:reference]
      expect(subject.total_price).to eq RESULT[:total_price]
    end
    it 'parses client' do
      RESULT[:client][:home_address].each do |k,v|
        expect(subject.client.home_address.send(k)).to eq v
      end
      expect(subject.client.name).to eq 'Jean Smith'
    end
    it 'parses signatures' do
      RESULT[:signatures].each_with_index do |sig, idx|
        sig.each do |k, v|
          expect(subject.signatures[idx].send(k)).to eq v
        end
      end
    end
    it 'parses items' do
      RESULT[:items].each do |ref, item|
        item.each do |k, v|
          expect(subject.items[ref].send(k)).to eq v
        end
      end
    end
  end
end

###

def bench
  Benchmark.ips do |x|
    x.report('dsl_parsers') { parse_dsl_parsers }
    x.report('xml-mapping') { parse_xml_mapping }
    x.compare!
  end
end
