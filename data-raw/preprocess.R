#' Download and install the GeoNames Gazetteer data.
#' @param dest The directory to download the files to.
#' @return The data frame.
geonames_install <- function(dest = getwd())
{
  url <- "http://download.geonames.org/export/dump/countryInfo.txt"
  destfile <- file.path(dest, basename(url))
  cat("download:", url, "->", destfile, "\n")
  utils::download.file(url, destfile)

  # read country
  fields.country <- c(
    iso = "c", iso3 = "c", iso_numeric = "i", fips = "c",
    country = "c", capital = "c",
    area = "d", population = "i",
    continent = "c", tld = "c",
    currency_code = "c", currency_name = "c",
    phone = "c", postal_code_format = "c", postal_code_regex = "c",
    languages = "c",
    geonameid = "i",
    neighbours = "c",
    equivalent_fips_code = "c"
  )
  cat("read...\n")
  lines <- readr::read_lines(destfile)
  lines <- lines[grep("^#", lines, invert = T)]
  country <- readr::read_tsv(
    lines,
    col_names = names(fields.country),
    col_types = paste(fields.country, collapse = "")
  )

  # download geoname
  url <- "http://download.geonames.org/export/dump/allCountries.zip"
  destfile <- file.path(dest, basename(url))
  cat("download:", url, "->", destfile, "\n")
  utils::download.file(url, destfile)

  # read geoname
  fields.geoname <- c(
    geonameid = "i",
    name = "c", asciiname = "c", alternatenames = "c",
    latitude = "d", longitude = "d",
    feature_class = "c", feature_code = "c",
    country_code = "c", cc2 = "c",
    admin1_code = "c", admin2_code = "c", admin3_code = "c", admin4_code = "c",
    population = "d", elevation = "i", dem = "c", timezone = "c",
    modification_date = "D"
  )
  cat("read...\n")
  fcode <- c(
    "ADM1", "ADM1H", "ADM2", "ADM2H", "ADM3", "ADM3H", "ADM4", "ADM4H",
    "PCLD", "PCLF", "TERR",
    "PPLA", "PPLA2", "PPLA3", "PPLA4", "PPLC", "PPLCH"
  )
  geoname <- readr::read_tsv_chunked(
    destfile,
    readr::DataFrameCallback$new(function(x, pos) x[x$feature_code %in% fcode, ]),
    chunk_size = 1000000,
    col_names = names(fields.geoname),
    col_types = paste(fields.geoname, collapse = "")
  )

  cat("compress...\n")
  usethis::use_data(country, geoname, overwrite = T, compress = "xz", version = 3)

  cat("done!")
}
