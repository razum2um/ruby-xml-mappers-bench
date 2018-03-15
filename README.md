# Compare various xml -> ruby datastructures

- [dsl_parsers](https://github.com/shredder-rull/dsl_parsers)
- [xml-mapping](https://github.com/multi-io/xml-mapping)

# Results

```
Calculating -------------------------------------
         dsl_parsers   468.000  i/100ms
         xml-mapping    33.000  i/100ms
-------------------------------------------------
         dsl_parsers      4.795k (± 3.2%) i/s -     24.336k
         xml-mapping    343.333  (± 3.2%) i/s -      1.716k

Comparison:
         dsl_parsers:     4794.8 i/s
         xml-mapping:      343.3 i/s - 13.97x slower
```

# Replicate

```sh
pry -r ./bench.rb
bench
```

```
rspec bench.rb
```
