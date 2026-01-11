# Set up the master discovery catalog

Creates the master discovery catalog SQLite database with the required
schema. This is a one-time admin task.

## Usage

``` r
db_setup_master(master_path)
```

## Arguments

- master_path:

  Path to the master catalog SQLite file

## Value

Invisibly returns the master_path

## Examples

``` r
if (FALSE) { # \dontrun{
db_setup_master("//CSO-NAS/DataLake/_master/discovery.sqlite")
} # }
```
