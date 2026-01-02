# Connect to the CSO hive parquet lake

Establishes a singleton connection to DuckDB and stores base path.

## Usage

``` r
db_connect(
  path = "//CSO-NAS/DataLake",
  db = ":memory:",
  threads = NULL,
  memory_limit = NULL,
  load_extensions = NULL
)
```

## Arguments

- path:

  Root path for the lake (e.g. "//CSO-NAS/DataLake")

- db:

  DuckDB database file path. Use ":memory:" for in-memory.

- threads:

  Number of DuckDB threads (NULL leaves default)

- memory_limit:

  e.g. "4GB" (NULL leaves default)

- load_extensions:

  character vector of extensions to install/load, e.g. c("httpfs")

## Value

DuckDB connection object

## Examples

``` r
if (FALSE) { # \dontrun{
# Connect to hive-partitioned data lake
db_connect(path = "//CSO-NAS/DataLake")

# With performance tuning
db_connect(path = "//CSO-NAS/DataLake", threads = 4, memory_limit = "8GB")
} # }
```
