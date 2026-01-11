# Feature Proposal: Public Metadata Catalog for Hive Mode

## Overview

This proposal addresses the need for a **universal metadata viewer** in Hive mode while maintaining data security isolation. The core idea is to allow datasets to be marked as "public" (discoverable) without granting access to the underlying data.

---

## Problem Statement

In Hive mode, data security works perfectly via folder permissions. However, this creates a discovery problem:

- Users can only see metadata for datasets they have folder access to
- There's no way to discover what datasets exist across the organisation
- A central data catalog/browser cannot show all available datasets
- Users must "know" what to ask for rather than being able to browse

**Goal**: Enable organisation-wide data discovery while maintaining data-level security.

---

## Proposed Solution

### Concept

Add a `public` parameter to `db_hive_write()` and related functions that:
1. Copies the dataset's `_metadata.json` to a shared catalog folder
2. Allows users to discover datasets via the catalog without data access
3. Provides functions to manage public/private status

### Catalog Folder Structure

```
//CSO-NAS/DataLake/
├── _catalog/                           ← Shared catalog folder (everyone has read access)
│   ├── Trade/
│   │   ├── Imports.json                ← Copy of metadata (public)
│   │   └── Exports.json                ← Copy of metadata (public)
│   ├── Labour/
│   │   └── Employment.json             ← Copy of metadata (public)
│   └── _catalog_index.json             ← Optional: aggregated index
│
├── Trade/                              ← Actual data (restricted access)
│   ├── Imports/
│   │   ├── year=2024/...
│   │   └── _metadata.json              ← Source metadata
│   └── Exports/
│       └── ...
└── Labour/                             ← Actual data (restricted access)
    └── ...
```

---

## API Design

### Option 1: Parameter on Write Functions

```r
# Mark dataset as public when writing
db_hive_write(
  data,
  section = "Trade",
  dataset = "Imports",
  partition_by = c("year", "month"),
  public = TRUE                          # NEW PARAMETER
)

# Preview also shows public status
db_preview_hive_write(
  data,
  section = "Trade",
  dataset = "Imports",
  public = TRUE
)
```

### Option 2: Separate Management Functions

```r
# Make an existing dataset public (copy JSON to catalog)
db_set_public(section = "Trade", dataset = "Imports")

# Make a dataset private (remove JSON from catalog)
db_set_private(section = "Trade", dataset = "Imports")

# Check if a dataset is public
db_is_public(section = "Trade", dataset = "Imports")

# List all public datasets (reads from catalog folder)
db_list_public()
```

### Option 3: Describe Function Extension

```r
# Update metadata and optionally publish to catalog
db_describe(
  section = "Trade",
  dataset = "Imports",
  description = "Monthly import values",
  owner = "Trade Section",
  public = TRUE                          # NEW PARAMETER
)
```

### Recommended Approach

Combine Options 1 and 2:
- `public` parameter on `db_hive_write()` for convenience
- Explicit `db_set_public()` / `db_set_private()` for existing datasets
- `db_list_public()` for catalog browsing

---

## Implementation Details

### Internal Helper Functions

```r
#' Get path to public catalog folder
#' @noRd
.db_catalog_path <- function() {
 base_path <- .db_get("data_path")
 file.path(base_path, "_catalog")
}

#' Get path to public metadata file for a dataset
#' @noRd
.db_public_metadata_path <- function(section, dataset) {
 catalog_path <- .db_catalog_path()
 file.path(catalog_path, section, paste0(dataset, ".json"))
}

#' Copy metadata to public catalog
#' @noRd
.db_publish_metadata <- function(section, dataset) {
 # Source: dataset's _metadata.json
 source_path <- .db_metadata_path(section, dataset)
 if (!file.exists(source_path)) {
   stop("No metadata exists for ", section, "/", dataset, ". Use db_describe() first.")
 }

 # Destination: _catalog/section/dataset.json
 dest_path <- .db_public_metadata_path(section, dataset)
 dir.create(dirname(dest_path), recursive = TRUE, showWarnings = FALSE)

 # Copy with additional catalog metadata
 metadata <- .db_read_metadata(source_path)
 metadata$catalog_published_at <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
 metadata$section <- section
 metadata$dataset <- dataset

 jsonlite::write_json(metadata, dest_path, pretty = TRUE, auto_unbox = TRUE)
 invisible(dest_path)
}

#' Remove metadata from public catalog
#' @noRd
.db_unpublish_metadata <- function(section, dataset) {
 dest_path <- .db_public_metadata_path(section, dataset)
 if (file.exists(dest_path)) {
   file.remove(dest_path)
 }
 invisible(TRUE)
}
```

### Public Functions

```r
#' Make a dataset discoverable in the public catalog
#'
#' @description Copies the dataset's metadata to the shared catalog folder,
#' allowing users to discover the dataset without having access to the data.
#'
#' @param section Section name
#' @param dataset Dataset name
#' @return Invisibly returns the path to the public metadata file
#' @export
db_set_public <- function(section, dataset) {
 section <- .db_validate_name(section, "section")
 dataset <- .db_validate_name(dataset, "dataset")

 .db_ensure_mode("hive")

 path <- .db_publish_metadata(section, dataset)
 message("Published ", section, "/", dataset, " to public catalog")
 invisible(path)
}

#' Remove a dataset from the public catalog
#'
#' @description Removes the dataset's metadata from the shared catalog folder.
#' The dataset and its data remain unchanged.
#'
#' @param section Section name
#' @param dataset Dataset name
#' @return Invisibly returns TRUE
#' @export
db_set_private <- function(section, dataset) {
 section <- .db_validate_name(section, "section")
 dataset <- .db_validate_name(dataset, "dataset")

 .db_ensure_mode("hive")

 .db_unpublish_metadata(section, dataset)
 message("Removed ", section, "/", dataset, " from public catalog")
 invisible(TRUE)
}

#' Check if a dataset is in the public catalog
#'
#' @param section Section name
#' @param dataset Dataset name
#' @return Logical TRUE/FALSE
#' @export
db_is_public <- function(section, dataset) {
 section <- .db_validate_name(section, "section")
 dataset <- .db_validate_name(dataset, "dataset")

 .db_ensure_mode("hive")

 path <- .db_public_metadata_path(section, dataset)
 file.exists(path)
}

#' List all datasets in the public catalog
#'
#' @description Lists all datasets that have been published to the public catalog.
#' This works even if you don't have access to the underlying data folders.
#'
#' @param section Optional section to filter by
#' @return A data frame with section, dataset, description, owner, tags
#' @export
db_list_public <- function(section = NULL) {
 .db_ensure_mode("hive")

 catalog_path <- .db_catalog_path()
 if (!dir.exists(catalog_path)) {
   return(data.frame(
     section = character(),
     dataset = character(),
     description = character(),
     owner = character(),
     tags = character(),
     stringsAsFactors = FALSE
   ))
 }

 # Find all JSON files in catalog
 pattern <- if (!is.null(section)) {
   file.path(catalog_path, section, "*.json")
 } else {
   file.path(catalog_path, "*", "*.json")
 }

 files <- Sys.glob(pattern)

 if (length(files) == 0) {
   return(data.frame(
     section = character(),
     dataset = character(),
     description = character(),
     owner = character(),
     tags = character(),
     stringsAsFactors = FALSE
   ))
 }

 # Read each metadata file
 results <- lapply(files, function(f) {
   meta <- jsonlite::fromJSON(f, simplifyVector = FALSE)
   data.frame(
     section = meta$section %||% basename(dirname(f)),
     dataset = meta$dataset %||% tools::file_path_sans_ext(basename(f)),
     description = meta$description %||% NA_character_,
     owner = meta$owner %||% NA_character_,
     tags = paste(meta$tags %||% character(), collapse = ", "),
     stringsAsFactors = FALSE
   )
 })

 do.call(rbind, results)
}
```

### Modified db_hive_write

```r
db_hive_write <- function(data,
                         section,
                         dataset,
                         partition_by = NULL,
                         mode = c("overwrite", "append", "ignore", "replace_partitions"),
                         compression = "zstd",
                         public = FALSE) {    # NEW PARAMETER

 # ... existing implementation ...

 # After successful write, handle public catalog
 if (isTRUE(public)) {
   # Check if metadata exists, create minimal if not
   meta_path <- .db_metadata_path(section, dataset)
   if (!file.exists(meta_path)) {
     .db_write_metadata(list(
       description = NULL,
       owner = NULL,
       tags = character()
     ), meta_path)
   }
   .db_publish_metadata(section, dataset)
   message("Published to public catalog")
 }

 invisible(qpath)
}
```

---

## Sync Considerations

### Keeping Catalog in Sync

The public catalog is a **copy** of metadata, which could become stale. Options:

#### Option A: Manual Sync (Simple)
- Users explicitly call `db_set_public()` to update
- Clear responsibility, no magic
- Metadata might drift from source

#### Option B: Auto-Sync on Describe (Recommended)
- When `db_describe()` is called, automatically update public copy if exists
- Keeps catalog current with minimal user action

```r
db_describe <- function(..., public = NULL) {
 # ... existing implementation ...

 # If already public or explicitly setting public, sync to catalog
 if (isTRUE(public) || (is.null(public) && db_is_public(section, dataset))) {
   .db_publish_metadata(section, dataset)
 }
}
```

#### Option C: Scheduled Sync
- Background job that syncs all public datasets
- More complex, requires external scheduling

### Handling Deleted Datasets

When a dataset is deleted:
- Should its public metadata be removed?
- Or kept as "archived" marker?

**Recommendation**: Add a `db_sync_catalog()` function that:
1. Checks all public metadata entries
2. Removes entries where source dataset no longer exists
3. Optionally updates entries that are stale

---

## Browser Integration

### db_browser() Updates

The Shiny browser should:
1. Add a "Public Catalog" tab showing `db_list_public()` results
2. Allow toggling public status from the UI (if user has write access)
3. Show "Public" badge on datasets that are in the catalog

### Search Integration

`db_search()` should optionally search the public catalog:

```r
db_search <- function(pattern, field = "name", include_public = TRUE) {
 # ... existing search of accessible datasets ...

 if (include_public) {
   # Also search public catalog (even for inaccessible datasets)
   public_matches <- .db_search_public_catalog(pattern, field)
   # Merge results, marking which are accessible vs discoverable-only
 }
}
```

---

## Security Implications

### What This Enables
- Users can discover ALL public datasets organisation-wide
- Users can see descriptions, owners, tags, column documentation
- Users can contact dataset owners to request access

### What This Does NOT Enable
- Users cannot read data from datasets they don't have folder access to
- The underlying security model remains unchanged
- Only **metadata** is shared, not data

### Permissions Model
```
//CSO-NAS/DataLake/
├── _catalog/          ← Everyone: Read-only
├── Trade/             ← Trade team: Read-write
├── Labour/            ← Labour team: Read-write
└── Shared/            ← Everyone: Read (or read-write)
```

---

## Migration Path

### For Existing Datasets

```r
# One-time migration: publish all datasets that have documentation
db_connect("//CSO-NAS/DataLake")

for (section in db_list_sections()) {
 for (dataset in db_list_datasets(section)) {
   docs <- db_get_docs(section, dataset)
   if (!is.null(docs$description)) {
     db_set_public(section, dataset)
   }
 }
}
```

---

## Open Questions

1. **Naming**: `public` vs `discoverable` vs `cataloged`?
2. **Granularity**: Should column-level docs also be in public catalog?
3. **Versioning**: Should catalog track metadata history?
4. **Access requests**: Should the system facilitate access requests to owners?
5. **Catalog index**: Generate `_catalog_index.json` for faster browsing?

---

## Alternatives Considered

### Alternative 1: Centralized Database
Store all metadata in a SQLite/PostgreSQL database that everyone can query.

**Pros**: Single source of truth, queryable
**Cons**: Introduces database dependency, more complex setup

### Alternative 2: Metadata in README files
Create README.md files in each section folder.

**Pros**: Human-readable, works with Git
**Cons**: Not programmatically queryable, doesn't solve discovery

### Alternative 3: External Data Catalog Tool
Use an external tool like DataHub, Amundsen, or OpenMetadata.

**Pros**: Full-featured, industry standard
**Cons**: Significant infrastructure, overkill for simple needs

---

## Implementation Priority

### Phase 1 (MVP)
- [ ] `db_set_public()` / `db_set_private()`
- [ ] `db_is_public()`
- [ ] `db_list_public()`
- [ ] `public` parameter on `db_describe()`

### Phase 2
- [ ] `public` parameter on `db_hive_write()`
- [ ] Auto-sync on `db_describe()`
- [ ] Browser integration

### Phase 3
- [ ] `db_sync_catalog()`
- [ ] Search integration
- [ ] Access request workflow
