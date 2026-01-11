# Unregister a section from the master catalog

Removes a section from the master discovery catalog. This does not
delete the section's data or catalog.

## Usage

``` r
db_unregister_section(section, master_path = NULL)
```

## Arguments

- section:

  Section name

- master_path:

  Path to master catalog (uses default if not specified)

## Value

Invisibly returns TRUE

## Examples

``` r
if (FALSE) { # \dontrun{
db_unregister_section("trade")
} # }
```
