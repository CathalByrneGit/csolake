# Switch to a different section

Disconnects from the current section and connects to a different one.
Requires master catalog to be configured.

## Usage

``` r
db_switch_section(section)
```

## Arguments

- section:

  Section name to switch to

## Value

DuckDB connection object (invisibly)

## Examples

``` r
if (FALSE) { # \dontrun{
db_lake_connect_section("trade")
db_switch_section("labour")
} # }
```
