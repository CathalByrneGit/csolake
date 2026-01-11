# Check if a dataset/table is in the public catalog

Check whether metadata has been published to the discovery catalog.

## Usage

``` r
db_is_public(section = NULL, dataset = NULL, schema = "main", table = NULL)
```

## Arguments

- section:

  Section name (hive mode), or NULL in DuckLake mode

- dataset:

  Dataset name (hive mode only)

- schema:

  Schema name (DuckLake mode, default "main")

- table:

  Table name (DuckLake mode only)

## Value

Logical TRUE if public, FALSE otherwise

## Examples

``` r
if (FALSE) { # \dontrun{
# Hive mode
db_connect("//CSO-NAS/DataLake")
db_is_public(section = "Trade", dataset = "Imports")

# DuckLake mode
db_lake_connect_section("trade")
db_is_public(schema = "main", table = "imports")
} # }
```
