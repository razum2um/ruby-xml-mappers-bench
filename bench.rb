require 'bundler'
Bundler.load
require 'benchmark/ips'

require_relative './xml_mapping'
require_relative './nokogiri_dsl_parsers'
require_relative './ox_dsl_parsers'

XMLFILE = File.read(File.expand_path('../xml/order.xml', __FILE__)).freeze

Benchmark.ips do |x|
  x.report('ox_dsl_parsers') { OxDslParsers.parse(XMLFILE) }
  x.report('nokogiri_dsl_parsers') { NokogiriDslParsers.parse(XMLFILE) }
  x.report('xml_mapping') { XmlMapping.parse(XMLFILE) }
  x.compare!
end
