# Compare various xml -> ruby datastructures

- [dsl_parsers](https://github.com/shredder-rull/dsl_parsers)
- [xml-mapping](https://github.com/multi-io/xml-mapping)

# Results

```
Calculating -------------------------------------
         dsl mapping   471.000  i/100ms
         xml mapping    33.000  i/100ms
-------------------------------------------------
         dsl mapping      4.827k (± 3.5%) i/s -     24.492k
         xml mapping    337.161  (± 4.2%) i/s -      1.683k

Comparison:
         dsl mapping:     4826.6 i/s
         xml mapping:      337.2 i/s - 14.32x slower
```

# Replicate

```sh
pry -r ./bench.rb
bench
```

```
rspec bench.rb
```
