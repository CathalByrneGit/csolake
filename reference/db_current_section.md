# Get current section

Returns the name of the currently connected section (DuckLake mode
only).

## Usage

``` r
db_current_section()
```

## Value

Section name or NULL if not connected to a section

## Examples

``` r
if (FALSE) { # \dontrun{
db_lake_connect_section("trade")
db_current_section()
#> [1] "trade"
} # }
```
