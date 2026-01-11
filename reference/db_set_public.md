# Make a dataset/table discoverable in the public catalog

Makes metadata discoverable organisation-wide.

In hive mode: Copies metadata to the shared `_catalog/` folder. In
DuckLake mode: Publishes to the master discovery catalog (requires
section).

## Usage

``` r
db_set_public(section = NULL, dataset = NULL, schema = "main", table = NULL)
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

Invisibly returns TRUE

## Examples

``` r
if (FALSE) { # \dontrun{
# Hive mode
db_connect("//CSO-NAS/DataLake")
db_set_public(section = "Trade", dataset = "Imports")

# DuckLake mode
db_lake_connect_section("trade")
db_set_public(schema = "main", table = "imports")
} # }
```
