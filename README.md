
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neogeonames <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/dnanto/neogeonames/blob/master/LICENSE)
[![](https://img.shields.io/badge/devel%20version-0.0.0.9000-blue.svg)](https://github.com/dnanto/neogeonames)
[![R build
status](https://github.com/dnanto/neogeonames/workflows/R-CMD-check/badge.svg)](https://github.com/dnanto/neogeonames/actions)
<!-- badges: end -->

The goal of neogeonames is to provide a useful subset of the [GeoNames
Gazetteer Data](http://download.geonames.org/export/dump/) with
functions to infer [ISO3166](https://en.wikipedia.org/wiki/ISO_3166)
codes for place name queries in a hierarchical manner without a REST
API. This package also includes coordinates and shape data for plotting
maps, language codes, and timezone data.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dnanto/neogeonames")
```

## Example

This is a basic example which shows you how to standardize potentially
misspelled place name into a set of ISO3166 codes.

``` r
library(neogeonames)
geo <- adminify_delim("USA: Fairfax County, Virginia", delim = "[:,]")
geo
#> $id
#>     ac0     ac1     ac2     ac3     ac4 
#> 6252001 6254928 4758041      NA      NA 
#> 
#> $ac
#>   ac0   ac1   ac2   ac3   ac4 
#>  "US"  "VA" "059"    NA    NA
paste(Filter(Negate(is.na), geo$ac), collapse = ".")
#> [1] "US.VA.059"
```

Here’s another example with misspelled name…

``` r
geo <- adminify_delim("USA: Furfax County, Virginia", delim = "[:,]")
geo
#> $id
#>     ac0     ac1     ac2     ac3     ac4 
#> 6252001 6254928 4758041      NA      NA 
#> 
#> $ac
#>   ac0   ac1   ac2   ac3   ac4 
#>  "US"  "VA" "059"    NA    NA
```

Use the geonameid to get the coordinates.

``` r
# get the id that occurs before the first NA value
idx <- which(is.na(c(geo$id, NA)))[[1]] - 1
with(geoname, geoname[geonameid == geo$id[idx], c("longitude", "latitude")])
#>        longitude latitude
#> 403895 -77.27622 38.83469
```

Here’s another example using regular expressions…

``` r
adminify_regex(
  "USA: Furfax County, Virginia",
  list(pattern = "(.+):\\s*(.+)\\s*,\\s*(.+)", names = c("ac0", "ac2", "ac1"))
)
#> $id
#>     ac0     ac1     ac2     ac3     ac4 
#> 6252001 6254928 4758041      NA      NA 
#> 
#> $ac
#>   ac0   ac1   ac2   ac3   ac4 
#>  "US"  "VA" "059"    NA    NA
```

Plot all feature codes in the US state of Virginia.

``` r
library(ggplot2)
df.virginia <- with(geoname, geoname[which(country_code == "US" & admin1_code == "VA"), ])
ggplot(df.virginia, aes(longitude, latitude)) + 
  geom_point(aes(fill = feature_code), pch = 21, size = 2, alpha = 0.75) + 
  guides(fill = guide_legend(nrow = 1)) +
  coord_map() +
  theme_minimal() +
  theme(legend.position = "bottom")
```

<img src="man/figuresunnamed-chunk-6-1.png" width="100%" />

Plot all world capitals.

``` r
df.capital <- with(geoname, geoname[which(feature_code == "PPLC"), ])
ggplot() + 
  geom_polygon(
    data = shape, color = "black", fill = "white",
    aes(long, lat, group = group)
  ) +
  geom_point(
    data = df.capital, fill = "blue", pch = 21,
    aes(longitude, latitude)
  ) +
  theme_minimal()
```

<img src="man/figuresunnamed-chunk-7-1.png" width="100%" />

Also, check out the `vignette("neogeonames")`.

## Data

  - Data updated: Mon Sep 14 14:45:03 2020
  - Data license: [CC
    BY 4.0](https://creativecommons.org/licenses/by/4.0/)
