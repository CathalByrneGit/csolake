# Search for columns

Search for columns by name across all datasets/tables.

## Usage

``` r
db_search_columns(pattern)
```

## Arguments

- pattern:

  Column name pattern (case-insensitive, matches partial strings)

## Value

A data.frame of matching columns with their table/dataset info

## Examples

``` r
if (FALSE) { # \dontrun{
db_connect()

# Find all columns containing "country"
db_search_columns("country")

# Find all ID columns
db_search_columns("_id")
} # }
```
