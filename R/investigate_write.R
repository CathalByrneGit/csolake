# #!/usr/bin/env Rscript
# # Investigation script for db_hive_write behavior
# # Run this locally to understand DuckDB's behavior
#
# library(DBI)
# library(duckdb)
#
# cat("=======================================================\n")
# cat("INVESTIGATION 1: Non-partitioned append behavior\n")
# cat("=======================================================\n\n")
#
# con <- dbConnect(duckdb())
# temp_dir <- tempfile(pattern = "invest_append_")
# dir.create(temp_dir)
#
# df1 <- data.frame(id = 1:3, value = c(10, 20, 30))
# df2 <- data.frame(id = 4:6, value = c(40, 50, 60))
#
# duckdb::duckdb_register(con, "df1", df1)
# duckdb::duckdb_register(con, "df2", df2)
#
# output_path <- file.path(temp_dir, "Test", "Data")
# dir.create(output_path, recursive = TRUE)
#
# # Simulate overwrite mode: write to specific file
# file_path <- file.path(output_path, "data.parquet")
# cat("Step 1: Writing to specific file (overwrite mode simulation)\n")
# cat("  Path:", file_path, "\n")
# dbExecute(con, sprintf("COPY df1 TO '%s' (FORMAT PARQUET, OVERWRITE)", file_path))
# cat("  Files created:\n")
# print(list.files(output_path, recursive = TRUE, full.names = FALSE))
#
# # Simulate append mode: write to directory
# cat("\nStep 2: Appending to directory (append mode simulation)\n")
# cat("  Path:", output_path, "\n")
# dbExecute(con, sprintf("COPY df2 TO '%s' (FORMAT PARQUET, APPEND, FILENAME_PATTERN 'data_{uuid}')", output_path))
# cat("  Files created:\n")
# print(list.files(output_path, recursive = TRUE, full.names = FALSE))
#
# # Read with glob
# glob_path <- file.path(output_path, "**", "*.parquet")
# cat("\nStep 3: Reading with glob:", glob_path, "\n")
# result <- tryCatch({
#   dbGetQuery(con, sprintf("SELECT * FROM read_parquet('%s', hive_partitioning=true)", glob_path))
# }, error = function(e) {
#   cat("  Error:", e$message, "\n")
#   NULL
# })
#
# if (!is.null(result)) {
#   cat("  Rows returned:", nrow(result), "\n")
#   cat("  Expected: 6\n")
#   if (nrow(result) == 6) {
#     cat("  ✓ PASS\n")
#   } else {
#     cat("  ✗ FAIL\n")
#     print(result)
#   }
# }
#
# dbDisconnect(con, shutdown = TRUE)
# unlink(temp_dir, recursive = TRUE)
#
# cat("\n=======================================================\n")
# cat("INVESTIGATION 2: Partition folder naming\n")
# cat("=======================================================\n\n")
#
# con <- dbConnect(duckdb())
# temp_dir <- tempfile(pattern = "invest_partition_")
# dir.create(temp_dir)
#
# df <- data.frame(
#   id = 1:4,
#   value = c(10, 20, 30, 40),
#   year = c(2023L, 2023L, 2024L, 2024L),  # Integer
#   month = c(1L, 2L, 1L, 2L)
# )
#
# duckdb::duckdb_register(con, "df", df)
#
# output_path <- file.path(temp_dir, "Test", "Data")
# dir.create(output_path, recursive = TRUE)
#
# cat("Writing partitioned data with integer columns...\n")
# dbExecute(con, sprintf(
#   "COPY df TO '%s' (FORMAT PARQUET, PARTITION_BY (year, month))",
#   output_path
# ))
#
# cat("\nDirectory structure created:\n")
# all_paths <- list.files(output_path, recursive = TRUE, full.names = FALSE, include.dirs = TRUE)
# for (p in sort(all_paths)) {
#   cat(" ", p, "\n")
# }
#
# # Check what the exact folder names are
# cat("\nFolder names at depth 1 (year level):\n")
# year_dirs <- list.dirs(output_path, recursive = FALSE, full.names = FALSE)
# print(year_dirs)
#
# if (length(year_dirs) > 0) {
#   cat("\nFolder names at depth 2 (month level) under first year:\n")
#   month_dirs <- list.dirs(file.path(output_path, year_dirs[1]), recursive = FALSE, full.names = FALSE)
#   print(month_dirs)
# }
#
# # Test if our expected path exists
# expected_path <- file.path(output_path, "year=2024", "month=1")
# cat("\nExpected path:", expected_path, "\n")
# cat("Exists:", dir.exists(expected_path), "\n")
#
# # What about with string coercion?
# expected_path2 <- file.path(output_path, "year=2024", "month=01")
# cat("\nAlternative path (zero-padded):", expected_path2, "\n")
# cat("Exists:", dir.exists(expected_path2), "\n")
#
# dbDisconnect(con, shutdown = TRUE)
# unlink(temp_dir, recursive = TRUE)
#
# cat("\n=======================================================\n")
# cat("INVESTIGATION 3: Replace partitions - what paths to delete?\n")
# cat("=======================================================\n\n")
#
# con <- dbConnect(duckdb())
# temp_dir <- tempfile(pattern = "invest_replace_")
# dir.create(temp_dir)
#
# df1 <- data.frame(
#   id = 1:4,
#   value = c(10, 20, 30, 40),
#   year = c(2023, 2023, 2024, 2024)  # Numeric (not integer)
# )
#
# duckdb::duckdb_register(con, "df1", df1)
#
# output_path <- file.path(temp_dir, "Test", "Data")
# dir.create(output_path, recursive = TRUE)
#
# cat("Writing partitioned data with NUMERIC year column...\n")
# dbExecute(con, sprintf(
#   "COPY df1 TO '%s' (FORMAT PARQUET, PARTITION_BY (year))",
#   output_path
# ))
#
# cat("\nDirectory structure:\n")
# print(list.dirs(output_path, recursive = TRUE, full.names = FALSE))
#
# # What paths does R think we should delete?
# cat("\nIf we wanted to replace year=2024 partition...\n")
# partition_by <- "year"
# data_to_replace <- data.frame(id = 5:6, value = 500:501, year = c(2024, 2024))
#
# part_vals <- unique(data_to_replace[partition_by])
# cat("Unique partition values in new data:\n")
# print(part_vals)
#
# to_delete <- vapply(seq_len(nrow(part_vals)), function(i) {
#   row <- part_vals[i, , drop = FALSE]
#   parts <- vapply(partition_by, function(col) {
#     paste0(col, "=", as.character(row[[col]]))
#   }, character(1))
#   file.path(output_path, paste(parts, collapse = .Platform$file.sep))
# }, character(1))
#
# cat("\nPaths R would try to delete:\n")
# print(to_delete)
#
# cat("\nDo these paths exist?\n")
# for (p in to_delete) {
#   cat("  ", p, ":", dir.exists(p), "\n")
# }
#
# # What paths actually exist?
# cat("\nActual paths that exist:\n")
# existing_dirs <- list.dirs(output_path, recursive = FALSE, full.names = TRUE)
# print(existing_dirs)
#
# dbDisconnect(con, shutdown = TRUE)
# unlink(temp_dir, recursive = TRUE)
#
# cat("\n=======================================================\n")
# cat("DONE - Review output above for insights\n")
# cat("=======================================================\n")
#
