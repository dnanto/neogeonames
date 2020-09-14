#' Download and install the GeoNames Gazetteer data.
#' No download occurs if the file already exists.
#' @param burl The base url to download the "countryInfo.txt" and "allCountries.zip" files.
#' @return The data frame.
neogeonames_update <- function(burl = "http://download.geonames.org/export/dump") {
  ## countryInfo ##

  # download
  url <- paste(burl, "countryInfo.txt", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

  ## read
  cat("read...\n")
  fields <- c(
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
  lines <- readr::read_lines(destfile)
  lines <- lines[grep("^#", lines, invert = T)]
  country <- readr::read_tsv(
    lines,
    col_names = names(fields),
    col_types = paste(fields, collapse = "")
  )

  ## geoname ##

  # download
  url <- paste(burl, "allCountries.zip", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

  # read
  cat("read...\n")
  fields <- c(
    geonameid = "i",
    name = "c", asciiname = "c", alternatenames = "c",
    latitude = "d", longitude = "d",
    feature_class = "c", feature_code = "c",
    country_code = "c", cc2 = "c",
    admin1_code = "c", admin2_code = "c", admin3_code = "c", admin4_code = "c",
    population = "d", elevation = "i", dem = "c", timezone = "c",
    modification_date = "D"
  )
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
    col_names = names(fields),
    col_types = paste(fields, collapse = ""),
    quote = ""
  )

  ## alternateNamesV2 ##

  # download
  url <- paste(burl, "alternateNamesV2.zip", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

  # read
  cat("read...\n")
  fields <- c(
    alternateid = "i", geonameid = "i", isolanguage = "c", alternateName = "c",
    isPreferredName = "l", isShortName = "l", isColloquial = "l", isHistoric = "l",
    from = "i", to = "i"
  )
  feature_code <- c("PCLI", "PCLH", "PCLS", "PCLD", "PCLF", "PCL", "TERR")
  alternate <- merge(
    readr::read_tsv(
      unz(destfile, "alternateNamesV2.txt"),
      col_names = names(fields),
      col_types = paste(fields, collapse = "")
    ),
    geoname[which(geoname$feature_code %in% feature_code), "geonameid"]
  )
  alternate$isPreferredName[is.na(alternate$isPreferredName)] <- F
  alternate$isShortName[is.na(alternate$isShortName)] <- F
  alternate$isColloquial[is.na(alternate$isColloquial)] <- F
  alternate$isHistoric[is.na(alternate$isHistoric)] <- F

  ## language ##

  # download
  url <- paste(burl, "iso-languagecodes.txt", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

  # read
  cat("read...\n")
  language <- setNames(readr::read_tsv(destfile), c("iso3", "iso2", "iso1", "name"))

  ## timezone ##

  # download
  url <- paste(burl, "timeZones.txt", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

  # read
  cat("read...\n")
  timezone <- setNames(
    readr::read_tsv(destfile),
    c("country", "timezone", "gmt", "dst", "rawOffset")
  )

  ## shape ##

  # download
  url <- paste(burl, "shapes_simplified_low.json.zip", sep = "/")
  destfile <- file.path(getwd(), basename(url))
  if (!file.exists(destfile)) {
    cat("download:", url, "->", destfile, "\n")
    utils::download.file(url, destfile)
  }

  unzip("shapes_simplified_low.json.zip")
  shape <- geojsonio::geojson_read("shapes_simplified_low.json", what = "sp")
  shape <- merge(
    ggplot2::fortify(shape),
    data.frame(id = 1:nrow(shape), geonameid = shape$geoNameId)
  )
  shape$geonameid <- as.integer(as.character(shape$geonameid))
  shape <- shape[c("geonameid", setdiff(names(shape), c("id", "geonameid")))]

  neogeonames_updated <- date()

  ## output ##

  cat("compress...\n")
  usethis::use_data(
    neogeonames_updated, country, geoname, alternate, language, timezone, shape,
    overwrite = T, compress = "xz", version = 3
  )

  cat("done!")
}
