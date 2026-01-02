# List sections in the hive data lake

Returns all top-level section folders in the data lake.

## Usage

``` r
db_list_sections()
```

## Value

Character vector of section names

## Examples

``` r
if (FALSE) { # \dontrun{
db_connect()
db_list_sections()
# [1] "Trade" "Labour" "Health" "Agriculture"
} # }
```
