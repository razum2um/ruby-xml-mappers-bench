# Compare various xml -> ruby datastructures

- [dsl_parsers (Ox/Nokogiri)](https://github.com/shredder-rull/dsl_parsers)
- [xml-mapping](https://github.com/multi-io/xml-mapping)

# Results

```
Calculating -------------------------------------
      ox_dsl_parsers   466.000  i/100ms
nokogiri_dsl_parsers    84.000  i/100ms
         xml_mapping    33.000  i/100ms
-------------------------------------------------
      ox_dsl_parsers      4.612k (± 5.5%) i/s -     23.300k
nokogiri_dsl_parsers    913.449  (±10.9%) i/s -      4.536k
         xml_mapping    326.724  (± 4.3%) i/s -      1.650k

Comparison:
      ox_dsl_parsers:     4611.6 i/s
nokogiri_dsl_parsers:      913.4 i/s - 5.05x slower
         xml_mapping:      326.7 i/s - 14.11x slower
```

# Replicate

```sh
ruby bench.rb
```

```
rspec spec.rb
```
