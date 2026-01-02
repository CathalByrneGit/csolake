# Read a CSO Dataset from hive-partitioned parquet (lazy)

Read a CSO Dataset from hive-partitioned parquet (lazy)

## Usage

``` r
db_hive_read(section, dataset, ...)
```

## Arguments

- section:

  The section name (e.g. "Trade")

- dataset:

  The dataset name (e.g. "Imports")

- ...:

  Additional named options passed into DuckDB read_parquet() in SQL form
  (e.g. union_by_name = TRUE). See examples below.

## Value

A lazy tbl_duckdb object

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic read
db_hive_read("Trade", "Imports")

# With options
db_hive_read("Trade", "Imports", union_by_name = TRUE, filename = TRUE)
} # }
```
