# Connect to a DuckLake section via master catalog

Connects to a registered section by looking up its catalog and data
paths from the master discovery catalog. This enables the `public`
parameter on
[`db_describe()`](https://cathalbyrnegit.github.io/datapond/reference/db_describe.md)
to sync to the master catalog.

## Usage

``` r
db_lake_connect_section(
  section,
  master_path = NULL,
  duckdb_db = ":memory:",
  catalog = NULL,
  catalog_type = NULL,
  threads = NULL,
  memory_limit = NULL
)
```

## Arguments

- section:

  Section name (must be registered in master catalog)

- master_path:

  Path to master catalog (uses default if not specified)

- duckdb_db:

  DuckDB database file path. Use ":memory:" for in-memory.

- catalog:

  DuckLake catalog name inside DuckDB

- catalog_type:

  Type of catalog backend (auto-detected from path if not specified)

- threads:

  Number of DuckDB threads (NULL leaves default)

- memory_limit:

  e.g. "4GB" (NULL leaves default)

## Value

DuckDB connection object

## Examples

``` r
if (FALSE) { # \dontrun{
# Connect to a section registered in master catalog
db_lake_connect_section("trade")

# Now db_describe(public=TRUE) will sync to master catalog
db_describe(table = "imports", description = "...", public = TRUE)
} # }
```
