#!/usr/bin/env Rscript

df.city <- read_tsv(
  "data/geonames/cities500.zip", 
  col_names = c(
    "geonameid", "name", "asciiname", "alternatenames", "latitude", "longitude",  
    "feature_class", "feature_code", "country_code", "cc2", 
    "admin1_code", "admin2_code", "admin3_code", "admin4_code",
    "population", "elevation", "dem", "timezone", "modification_date"
  ), 
  col_types = "iccccccccccccciiccT"
)

df.country <-
  read_lines("data/geonames/countryInfo.txt") %>%
  enframe(name = NULL) %>%
  filter(!startsWith(value, "#")) %>%
  pull(value) %>%
  read_tsv(col_names = c(
    "iso", "iso3",	"iso_num", "fips", "country", "capital", "area",
    "population",	"continent", "tld",	"currency_code",
    "currency_name", "phone", "postal_code_format", "postal_code_regex",
    "languages", "geonameid", "neighbours", "equivalent_fips_code"
  ))

df.admin.1 <- read_tsv(
  "data/geonames/admin1CodesASCII.txt", 
  col_names = c("code", "name", "name_ascii", "geonameid"),
  col_types = "ccci"
) %>% separate("code", c("iso", "lvl.1"), sep = "\\.", remove = F)

df.admin.2 <- read_tsv(
  "data/geonames/admin2Codes.txt",
  col_names = c("code", "name", "name_ascii", "geonameid"),
  col_types = "ccci"
) %>% separate("code", c("iso", "lvl.1", "lvl.2"), sep = "\\.", remove = F)

code <- c("cn", "cc2", "cc3", "ac1", "ac1n", "ac2", "ac2n") %>% setNames(seq_along(.), .)

is.int0 <- function(x) identical(x, integer(0))
is.iso <- function(val) any(toupper(val) == df.country$iso, na.rm = T)
is.iso3 <- function(val) any(toupper(val) == df.country$iso3, na.rm = T)
is.country <- function(val) any(val == df.country$country, na.rm = T)

country.letters <- paste(unique(strsplit(paste(df.country$country, collapse = ""), "")[[1]]), collapse = "")
country.regex <- paste0("[^", str_replace(country.letters, "-", "\\\\-"), "]")
country.sanitize <- function(value) str_squish(str_replace_all(value, country.regex, " "))
sani.country <- country.sanitize.vec <- Vectorize(country.sanitize, c("value"), USE.NAMES = F)

countrify <- function(val, n = 1, max.distance = 0.1)
{
  result <- NA
  val <- toupper(val)
  if (idx <- match(val, df.country$iso, nomatch = F)) result <- df.country[[idx, "iso"]]
  else if (idx <- match(val, df.country$iso3, nomatch = F)) result <- df.country[[idx, "iso"]]
  else if (idx <- match(val, toupper(df.country$country), nomatch = F)) result <- df.country[[idx, "iso"]]
  else
  {
    idx <- agrep(val, df.country$country, ignore.case = T, max.distance = max.distance)
    if (!is.int0(idx) & length(idx) <= n) result <- df.country[[idx[[1]], "iso"]]
  }
  result
}

codify.1 <- function(val, cc2 = NA, n = 1, max.distance = 0.1)
{
  result <- NA
  val <- toupper(val)
  
  df <- df.admin.1
  if (!is.na(cc2)) df <- filter(df, iso == cc2)
  
  if (idx <- match(val, df$lvl.1, nomatch = F)) result <- df[[idx, "code"]]
  else if (idx <- match(val, toupper(df$name_ascii), nomatch = F)) result <- df[[idx, "code"]]
  else
  {
    idx <- agrep(val, df$name_ascii, ignore.case = T, max.distance = max.distance)
    if (!is.int0(idx) & length(idx) <= n) result <- df[[idx[[1]], "code"]]
  }
  
  result
}

codify.2 <- function(val, cc2 = NA, ac1 = NA, n = 1, max.distance = 0.1)
{
  result <- NA
  val <- toupper(val)
  
  df <- df.admin.2
  if (!is.na(cc2)) df <- filter(df, iso == cc2)
  if (!is.na(ac1)) df <- filter(df, iso == ac1)
  
  if (idx <- match(val, df$lvl.2, nomatch = F)) result <- df[[idx, "code"]]
  else if (idx <- match(val, toupper(df$name_ascii), nomatch = F)) result <- df[[idx, "code"]]
  else
  {
    idx <- agrep(val, df$name_ascii, ignore.case = T, max.distance = max.distance)
    if (!is.int0(idx) & length(idx) <= n) result <- df[[idx[[1]], "code"]]
  }
  
  result
}

process_regx <- function(val, regx, n = 1)
{
  tokens <- setNames(tail(str_match(val, regx$pattern)[1,], -1), regx$names)
  result <- list(cn = NA, ac1 = NA, ac2 = NA, ac3 = NA, ac4 = NA)
  
  if (!any(is.na(tokens)))
  {
    # process admin code hierarchy
    for (name in names(sort(code[regx$names])))
    {
      if (name == "cn") 
      {  
        result[[name]] <- countrify(tokens[[name]], n = n)
      }
      else if (name == "ac1")
      {
        result[[name]] <- codify.1(tokens[[name]], cc2 = result$cn, n = n)
      }
      else if (name == "ac2")
      {
        result[[name]] <- codify.2(tokens[[name]], cc2 = result$cn, ac1 = result$ac1, n = n)
      }
    }
  }
  
  result
}

process_regx_list <- function(val, regx_list)
{
  coalesce(!!!lapply(regx_list, process_regx, val = val))
}

