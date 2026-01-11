# Remove a dataset/table from the public catalog

Removes metadata from the public discovery catalog. The dataset/table
and its data remain unchanged.

## Usage

``` r
db_set_private(section = NULL, dataset = NULL, schema = "main", table = NULL)
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
db_set_private(section = "Trade", dataset = "Imports")

# DuckLake mode
db_lake_connect_section("trade")
db_set_private(schema = "main", table = "imports")
} # }
```
