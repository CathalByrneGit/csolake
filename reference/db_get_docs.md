# Get documentation for a dataset or table

Retrieve documentation metadata for a dataset or table.

## Usage

``` r
db_get_docs(section = NULL, dataset = NULL, schema = "main", table = NULL)
```

## Arguments

- section:

  Section name (hive mode only)

- dataset:

  Dataset name (hive mode only)

- schema:

  Schema name (DuckLake mode, default "main")

- table:

  Table name (DuckLake mode only)

## Value

A list containing description, owner, tags, and column documentation

## Examples

``` r
if (FALSE) { # \dontrun{
db_connect()
db_get_docs("Trade", "Imports")
} # }
```
