# Check if a hive dataset exists

Check if a hive dataset exists

## Usage

``` r
db_dataset_exists(section, dataset)
```

## Arguments

- section:

  The section name

- dataset:

  The dataset name

## Value

Logical TRUE if exists, FALSE otherwise

## Examples

``` r
if (FALSE) { # \dontrun{
db_connect()
db_dataset_exists("Trade", "Imports")
# [1] TRUE
} # }
```
