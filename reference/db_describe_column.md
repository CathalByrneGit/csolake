# Describe a column

Add documentation to a specific column in a dataset or table.

In hive mode, you can set `public = TRUE` to include the column
documentation in the public catalog. The dataset must already be public
(use `db_describe(public = TRUE)` first).

## Usage

``` r
db_describe_column(
  section = NULL,
  dataset = NULL,
  schema = "main",
  table = NULL,
  column,
  description = NULL,
  units = NULL,
  notes = NULL,
  public = NULL
)
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

- column:

  Column name to document

- description:

  Description of what the column contains

- units:

  Units of measurement (optional)

- notes:

  Additional notes (optional)

- public:

  Logical. If TRUE, sync column docs to public catalog (requires dataset
  to already be public). If NULL (default), auto-sync if dataset is
  already public. (Hive mode only)

## Value

Invisibly returns the column metadata

## Examples

``` r
if (FALSE) { # \dontrun{
db_connect()
db_describe_column(
  section = "Trade",
  dataset = "Imports",
  column = "value",
  description = "Import value in thousands",
  units = "EUR (thousands)",
  public = TRUE
)
} # }
```
