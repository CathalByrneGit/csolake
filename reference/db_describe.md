# Describe a dataset or table

Add documentation metadata to a dataset (hive mode) or table (DuckLake
mode). Metadata includes description, owner, and tags.

In hive mode, you can set `public = TRUE` to publish the metadata to a
shared catalog folder, making it discoverable organisation-wide without
granting access to the underlying data.

## Usage

``` r
db_describe(
  section = NULL,
  dataset = NULL,
  schema = "main",
  table = NULL,
  description = NULL,
  owner = NULL,
  tags = NULL,
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

- description:

  Free-text description of the dataset/table

- owner:

  Owner name or team responsible for this data

- tags:

  Character vector of tags for categorization

- public:

  Logical. If TRUE, publish metadata to the shared catalog folder. If
  FALSE, remove from catalog. If NULL (default), keep current public
  status and auto-sync if already public. (Hive mode only)

## Value

Invisibly returns the metadata list

## Examples

``` r
if (FALSE) { # \dontrun{
# Hive mode
db_connect()
db_describe(
  section = "Trade",
  dataset = "Imports",
  description = "Monthly import values by country and commodity code",
  owner = "Trade Section",
  tags = c("trade", "monthly", "official"),
  public = TRUE
)

# DuckLake mode
db_lake_connect()
db_describe(
  table = "imports",
  description = "Monthly import values",
  owner = "Trade Section"
)
} # }
```
