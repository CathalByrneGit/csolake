# List datasets within a section

Returns all datasets (subfolders) within a given section.

## Usage

``` r
db_list_datasets(section)
```

## Arguments

- section:

  The section name (e.g. "Trade")

## Value

Character vector of dataset names

## Examples

``` r
if (FALSE) { # \dontrun{
db_connect()
db_list_datasets("Trade")
# [1] "Imports" "Exports" "Balance"
} # }
```
