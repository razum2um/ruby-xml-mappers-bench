require 'bundler'
Bundler.load
require 'rspec'
require 'benchmark/ips'

require_relative './xml_mapping'
require_relative './nokogiri_dsl_parsers'
require_relative './ox_dsl_parsers'

XMLFILE = File.read(File.expand_path('../xml/order.xml', __FILE__)).freeze

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
  describe 'ox_dsl_mapping' do
    subject { OxDslParsers.parse(XMLFILE) }
    it 'parses order' do
      expect(subject).to eq RESULT
    end
  end

  describe 'nokogiri_dsl_mapping' do
    subject { NokogiriDslParsers.parse(XMLFILE) }
    it 'parses order' do
      expect(subject).to eq RESULT
    end
  end

  describe 'xml-mapping' do
    subject { XmlMapping.parse(XMLFILE) }
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
    x.report('ox_dsl_parsers') { OxDslParsers.parse(XMLFILE) }
    x.report('nokogiri_dsl_parsers') { NokogiriDslParsers.parse(XMLFILE) }
    x.report('xml_mapping') { XmlMapping.parse(XMLFILE) }
    x.compare!
  end
end
