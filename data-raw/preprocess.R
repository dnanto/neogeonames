#' Download and install the GeoNames Gazetteer data.
#' No download occurs if the file already exists.
#' @param burl The base url to download the "countryInfo.txt" and "allCountries.zip" files.
#' @return The data frame.
geonames_install <- function(burl = "http://download.geonames.org/export/dump") {
  # download country
  url <- paste(burl, "countryInfo.txt", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

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

  # download country
  url <- paste(burl, "allCountries.zip", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

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
  feature_codes <- c(
    # A country, state, region,...
    "ADM1", "ADM1H", "ADM2", "ADM2H", "ADM3", "ADM3H", "ADM4", "ADM4H",
    "PCL", "PCLD", "PCLF", "PCLH", "PCLI", "PCLS", "TERR",
    # P city, village,...
    "PPLA", "PPLA2", "PPLA3", "PPLA4", "PPLC"
  )
  keys <- c(
    "geonameid", "name", "asciiname", "latitude", "longitude",
    "feature_code", "country_code", "admin1_code", "admin2_code", "admin3_code", "admin4_code",
    "modification_date"
  )
  geoname <- readr::read_tsv_chunked(
    destfile,
    readr::DataFrameCallback$new(function(x, pos) x[x$feature_code %in% feature_codes, keys]),
    chunk_size = 1000000,
    col_names = names(fields.geoname),
    col_types = paste(fields.geoname, collapse = ""),
    quote = ""
  )

  cat("compress...\n")
  usethis::use_data(country, geoname, overwrite = T, compress = "xz", version = 3)

  cat("done!")
}
