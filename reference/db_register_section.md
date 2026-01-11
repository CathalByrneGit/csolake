# Register a section in the master catalog

Registers a DuckLake section (with its own catalog) in the master
discovery catalog, making it discoverable organisation-wide.

## Usage

``` r
db_register_section(
  section,
  catalog_path,
  data_path,
  description = NULL,
  owner = NULL,
  master_path = NULL
)
```

## Arguments

- section:

  Section name (e.g., "trade", "labour")

- catalog_path:

  Path to the section's DuckLake catalog file

- data_path:

  Path to the section's data folder

- description:

  Optional description of the section

- owner:

  Optional owner/team name

- master_path:

  Path to master catalog (uses default if not specified)

## Value

Invisibly returns TRUE

## Examples

``` r
if (FALSE) { # \dontrun{
db_register_section(
  section = "trade",
  catalog_path = "//CSO-NAS/DataLake/trade/catalog.sqlite",
  data_path = "//CSO-NAS/DataLake/trade/data",
  owner = "Trade Team"
)
} # }
```
