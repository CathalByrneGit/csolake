# List all datasets/tables in the public catalog

Lists all entries published to the discovery catalog. This works even if
you don't have access to the underlying data, allowing organisation-wide
data discovery.

## Usage

``` r
db_list_public(section = NULL)
```

## Arguments

- section:

  Optional section to filter by

## Value

A data.frame with discovery information

## Examples

``` r
if (FALSE) { # \dontrun{
# Hive mode
db_connect("//CSO-NAS/DataLake")
db_list_public()
db_list_public(section = "Trade")

# DuckLake mode - lists from master catalog
db_lake_connect_section("trade")
db_list_public()
db_list_public(section = "trade")
} # }
```
