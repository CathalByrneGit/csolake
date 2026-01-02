# Create a new schema in DuckLake

Create a new schema in DuckLake

## Usage

``` r
db_create_schema(schema)
```

## Arguments

- schema:

  Schema name to create

## Value

Invisibly returns the schema name

## Examples

``` r
if (FALSE) { # \dontrun{
db_lake_connect()
db_create_schema("trade")
} # }
```
