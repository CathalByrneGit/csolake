# Sync the public catalog with source metadata

Scans the public catalog and updates entries from their source metadata.
Optionally removes entries where the source no longer exists.

## Usage

``` r
db_sync_catalog(remove_orphans = FALSE)
```

## Arguments

- remove_orphans:

  Logical. If TRUE, remove catalog entries where the source no longer
  exists. Default FALSE.

## Value

Invisibly returns a list with counts of synced, removed, and errors

## Examples

``` r
if (FALSE) { # \dontrun{
# Hive mode
db_connect("//CSO-NAS/DataLake")
db_sync_catalog()
db_sync_catalog(remove_orphans = TRUE)

# DuckLake mode
db_lake_connect_section("trade")
db_sync_catalog()
} # }
```
