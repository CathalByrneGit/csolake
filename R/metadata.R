# R/metadata.R

#' List DuckLake snapshots
#' 
#' @description Returns all snapshots (versions) for the connected DuckLake catalog,
#' including snapshot ID, timestamp, and commit metadata.
#' @return A data.frame of snapshot information
#' @examples
#' \dontrun{
#' db_lake_connect()
#' db_snapshots()
#' }
#' @export
db_snapshots <- function() {
  con <- .db_get_con()
  if (is.null(con)) {
    stop("Not connected. Use db_lake_connect() first.", call. = FALSE)
  }
  
  curr_mode <- .db_get("mode")
  if (!is.null(curr_mode) && curr_mode != "ducklake") {
    stop("Connected in hive mode. Snapshots are only available for DuckLake. Reconnect with db_lake_connect().", call. = FALSE)
  }
  
  catalog <- .db_get("catalog")
  if (is.null(catalog)) {
    stop("No DuckLake catalog configured. Use db_lake_connect() first.", call. = FALSE)
  }
  
  sql <- glue::glue("FROM ducklake_snapshots({.db_sql_quote(catalog)})")
  DBI::dbGetQuery(con, sql)
}

#' List tables and file stats tracked by DuckLake
#' 
#' @description Returns information about all tables in the connected DuckLake catalog,
#' including row counts, file counts, and storage statistics.
#' @return A data.frame of table information
#' @examples
#' \dontrun{
#' db_lake_connect()
#' db_catalog()
#' }
#' @export
db_catalog <- function() {
  con <- .db_get_con()
  if (is.null(con)) {
    stop("Not connected. Use db_lake_connect() first.", call. = FALSE)
  }
  
  curr_mode <- .db_get("mode")
  if (!is.null(curr_mode) && curr_mode != "ducklake") {
    stop("Connected in hive mode. Catalog info is only available for DuckLake. Reconnect with db_lake_connect().", call. = FALSE)
  }
  
  catalog <- .db_get("catalog")
  if (is.null(catalog)) {
    stop("No DuckLake catalog configured. Use db_lake_connect() first.", call. = FALSE)
  }
  
  sql <- glue::glue("FROM ducklake_table_info({.db_sql_quote(catalog)})")
  DBI::dbGetQuery(con, sql)
}