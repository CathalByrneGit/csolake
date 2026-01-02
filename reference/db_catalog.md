# List tables and file stats tracked by DuckLake

Returns information about all tables in the connected DuckLake catalog,
including row counts, file counts, and storage statistics.

## Usage

``` r
db_catalog()
```

## Value

A data.frame of table information

## Examples

``` r
if (FALSE) { # \dontrun{
db_lake_connect()
db_catalog()
} # }
```
