# R/read.R

# internal: build the parquet glob path
.db_dataset_glob <- function(base_path, section, dataset) {
  file.path(base_path, section, dataset, "**", "*.parquet")
}

#' Read a CSO Dataset from hive-partitioned parquet (lazy)
#' 
#' @param section The section name (e.g. "Trade")
#' @param dataset The dataset name (e.g. "Imports")
#' @param ... Additional named options passed into DuckDB read_parquet() in SQL form
#'   (e.g. union_by_name = TRUE). See examples below.
#' @return A lazy tbl_duckdb object
#' @examples
#' \dontrun{
#' # Basic read
#' db_hive_read("Trade", "Imports")
#' 
#' # With options
#' db_hive_read("Trade", "Imports", union_by_name = TRUE, filename = TRUE)
#' }
#' @export
db_hive_read <- function(section, dataset, ...) {
  section <- .db_validate_name(section, "section")
  dataset <- .db_validate_name(dataset, "dataset")

  con <- .db_get_con()
  if (is.null(con)) {
    stop("Not connected. Use db_connect() first.", call. = FALSE)
  }
  
  mode <- .db_get("mode")
  if (!is.null(mode) && mode != "hive") {
    stop("Connected in DuckLake mode. Use db_lake_read() instead, or reconnect with db_connect().", call. = FALSE)
  }

  base_path <- .db_get("data_path")
  if (is.null(base_path)) {
    stop("No data path configured.", call. = FALSE)
  }

  glob_path <- .db_dataset_glob(base_path, section, dataset)

  # translate ... into SQL options like: union_by_name=true, filename=true
  dots <- list(...)
  opt_sql <- ""
  if (length(dots) > 0) {
    # enforce named args only (prevents accidental positional junk)
    if (is.null(names(dots)) || any(names(dots) == "")) {
      stop("All ... arguments must be named (e.g. union_by_name = TRUE).", call. = FALSE)
    }
    # convert logical to SQL true/false; quote character strings
    dots2 <- lapply(dots, function(v) {
      if (is.logical(v)) {
        ifelse(isTRUE(v), "true", "false")
      } else if (is.numeric(v)) {
        as.character(v)
      } else if (is.character(v) && length(v) == 1) {
        .db_sql_quote(v)
      } else {
        stop("Unsupported option type in ...: ", paste(class(v), collapse = "/"), call. = FALSE)
      }
    })
    opt_sql <- paste0(", ", paste(paste0(names(dots2), "=", unlist(dots2)), collapse = ", "))
  }

  # build query - wrap in SELECT for dplyr compatibility
  query <- paste0(
    "SELECT * FROM read_parquet(",
    .db_sql_quote(glob_path),
    ", hive_partitioning=true",
    opt_sql,
    ")"
  )

  # Permission/existence check: attempt to read one row
  # (This avoids Sys.glob on remote FS and yields more accurate errors)
  ok <- TRUE
  err <- NULL
  tryCatch({
    DBI::dbGetQuery(con, paste0(query, " LIMIT 1"))
  }, error = function(e) {
    ok <<- FALSE
    err <<- e$message
  })

  if (!ok) {
    stop(
      "Unable to read dataset '", section, "/", dataset, "'.\n",
      "Possible causes:\n",
      "
 - No parquet files exist at the expected location\n",
      " - You do not have access rights to this section/dataset\n",
      " - Network path is unavailable\n\n",
      "DuckDB message: ", err,
      call. = FALSE
    )
  }

  dplyr::tbl(con, dplyr::sql(query))
}


#' Read a DuckLake table (lazy)
#'
#' @param schema Schema name (default "main")
#' @param table Table name
#' @param version Optional integer snapshot version for time travel
#' @param timestamp Optional timestamp string for time travel (e.g. "2025-05-26 00:00:00")
#' @return A lazy tbl_duckdb object
#' @examples
#' \dontrun{
#' # Basic read
#' db_lake_read(table = "imports")
#' 
#' # From a specific schema
#' db_lake_read(schema = "trade", table = "imports")
#' 
#' # Time travel by version
#' db_lake_read(table = "imports", version = 5)
#' 
#' # Time travel by timestamp
#' db_lake_read(table = "imports", timestamp = "2025-05-26 00:00:00")
#' }
#' @export
db_lake_read <- function(schema = "main", table, version = NULL, timestamp = NULL) {
  schema <- .db_validate_name(schema, "schema")
  table  <- .db_validate_name(table, "table")

  con <- .db_get_con()
  if (is.null(con)) {
    stop("Not connected. Use db_lake_connect() first.", call. = FALSE)
  }
  
  mode <- .db_get("mode")
  if (!is.null(mode) && mode != "ducklake") {
    stop("Connected in hive mode. Use db_hive_read() instead, or reconnect with db_lake_connect().", call. = FALSE)
  }

  catalog <- .db_get("catalog")
  if (is.null(catalog)) {
    stop("No DuckLake catalog configured. Use db_lake_connect() first.", call. = FALSE)
  }

  if (!is.null(version) && !is.null(timestamp)) {
    stop("Use only one of 'version' or 'timestamp', not both.", call. = FALSE)
  }

  at_sql <- ""
  if (!is.null(version)) {
    at_sql <- glue::glue(" AT (VERSION => {as.integer(version)})")
  } else if (!is.null(timestamp)) {
    at_sql <- glue::glue(" AT (TIMESTAMP => {.db_sql_quote(timestamp)})")
  }

  from_sql <- glue::glue("{catalog}.{schema}.{table}{at_sql}")
  query <- glue::glue("SELECT * FROM {from_sql}")

  # Permission/existence check
  ok <- TRUE
  err <- NULL
  tryCatch({
    DBI::dbGetQuery(con, paste0(query, " LIMIT 1"))
  }, error = function(e) {
    ok <<- FALSE
    err <<- e$message
  })

  if (!ok) {
    stop(
      "Unable to read table '", catalog, ".", schema, ".", table, "'.\n",
      "Possible causes:\n",
      " - Table does not exist\n",
      " - You do not have access rights\n",
      " - Invalid version/timestamp for time travel\n\n",
      "DuckDB message: ", err,
      call. = FALSE
    )
  }

  dplyr::tbl(con, dplyr::sql(query))
}