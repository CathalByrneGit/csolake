#!/usr/bin/env Rscript
# render_vignettes.R - Render vignettes to both HTML and Markdown
#
# Usage: Rscript render_vignettes.R
# Or: source("render_vignettes.R") from R

library(rmarkdown)

# Get the vignettes directory
vignettes_dir <- "vignettes"
output_dir <- "doc"

# Create output directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Find all Rmd files
rmd_files <- list.files(vignettes_dir, pattern = "\\.Rmd$", full.names = TRUE)

for (rmd_file in rmd_files) {
  base_name <- tools::file_path_sans_ext(basename(rmd_file))

  cat("\n========================================\n")
  cat("Rendering:", base_name, "\n")
  cat("========================================\n")



  # Render to Markdown (GitHub-flavored)
  cat("  -> Markdown...")
  tryCatch({
    rmarkdown::render(
      rmd_file,
      output_format = rmarkdown::md_document(
        variant = "gfm",  # GitHub-flavored markdown
        preserve_yaml = TRUE
      ),
      output_file = paste0(base_name, ".md"),
      output_dir = output_dir,
      quiet = TRUE
    )
    cat(" done\n")
  }, error = function(e) {
    cat(" ERROR:", e$message, "\n")
  })
}

cat("\n========================================\n")
cat("Output files in:", output_dir, "\n")
cat(list.files(output_dir), sep = "\n")
cat("========================================\n")
