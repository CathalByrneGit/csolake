# Upsert into a DuckLake table using MERGE INTO

Upsert into a DuckLake table using MERGE INTO

## Usage

``` r
db_upsert(
  data,
  schema = "main",
  table,
  by,
  strict = TRUE,
  update_cols = NULL,
  commit_author = NULL,
  commit_message = NULL
)
```

## Arguments

- data:

  data.frame / tibble

- schema:

  Schema name (default "main")

- table:

  Table name

- by:

  Character vector of key columns used to match rows

- strict:

  If TRUE (default), refuse to upsert if duplicates exist in `data` for
  the `by` key.

- update_cols:

  Controls which columns to update on match:

  - NULL (default): update all columns

  - character(0): insert-only (no updates on match)

  - character vector: update only specified columns

- commit_author:

  Optional DuckLake commit author

- commit_message:

  Optional DuckLake commit message

## Value

Invisibly returns the qualified table name

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic upsert by id
db_upsert(my_data, table = "products", by = "product_id")

# Composite key
db_upsert(my_data, table = "sales", by = c("region", "date"))

# Update only specific columns
db_upsert(my_data, table = "products", by = "product_id",
          update_cols = c("price", "updated_at"))

# Insert-only (no updates)
db_upsert(my_data, table = "events", by = "event_id",
          update_cols = character(0))

# With commit metadata
db_upsert(my_data, table = "products", by = "product_id",
          commit_author = "jsmith",
          commit_message = "Price update batch")
} # }
```
