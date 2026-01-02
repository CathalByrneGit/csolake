# Write a DuckLake table (overwrite/append)

Write a DuckLake table (overwrite/append)

## Usage

``` r
db_lake_write(
  data,
  schema = "main",
  table,
  mode = c("overwrite", "append"),
  commit_author = NULL,
  commit_message = NULL
)
```

## Arguments

- data:

  data.frame/tibble

- schema:

  Schema name (default "main")

- table:

  Table name

- mode:

  "overwrite" or "append"

- commit_author:

  Optional author for DuckLake commit metadata

- commit_message:

  Optional message for DuckLake commit metadata

## Value

Invisibly returns the qualified table name

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic overwrite
db_lake_write(my_data, table = "imports")

# With schema
db_lake_write(my_data, schema = "trade", table = "imports")

# Append mode with commit info
db_lake_write(my_data, table = "imports", mode = "append",
              commit_author = "jsmith", 
              commit_message = "Added Q3 data")
} # }
```
