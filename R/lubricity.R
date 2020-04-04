# geonames ata download, parsing, and setup

geonames_download <- function(root = getwd(), url = "http://download.geonames.org/export/dump")
{
  c("countryInfo.txt", "admin1CodesASCII.txt", "admin2Codes.txt") %>%
    sapply(function(target) {
      dest <- file.path(root, target)
      utils::download.file(file.path(url, target), dest)
      dest
    })
}

geonames_read_country <- function(path)
{
  read_lines(path) %>%
    enframe(name = NULL) %>%
    dplyr::filter(!startsWith(value, "#")) %>%
    pull(value) %>%
    read_tsv(col_names = c(
      "iso", "iso3",	"iso_num", "fips", "country", "capital", "area", "population","continent",
      "tld",	"currency_code", "currency_name", "phone", "postal_code_format", "postal_code_regex",
      "languages", "geonameid", "neighbours", "equivalent_fips_code"
    ))
}

geonames_read_admin_1 <- function(path)
{
  read_tsv(path, col_names = c("code", "name", "name_ascii", "geonameid"), col_types = "ccci") %>%
    separate("code", c("iso", "lvl.1"), sep = "\\.", remove = F)
}

geonames_read_admin_2 <- function(path)
{
  read_tsv(path, col_names = c("code", "name", "name_ascii", "geonameid"), col_types = "ccci") %>%
    separate("code", c("iso", "lvl.1", "lvl.2"), sep = "\\.", remove = F)
}

geonames_install <- function(url = "http://download.geonames.org/export/dump")
{
  result <- geonames_download(url = url)
  country <-
    geonames_read_country(result["countryInfo.txt"]) %>%
    rename(name = country) %>%
    select(iso, iso3, name)
  admin1 <-
    geonames_read_admin_1(result["admin1CodesASCII.txt"]) %>%
    select(-name) %>%
    rename(name = name_ascii) %>%
    separate("code", c("iso", "lvl.1"), sep = "\\.", remove = F) %>%
    select(code, iso, lvl.1, name)
  admin2 <-
    geonames_read_admin_2(result["admin2Codes.txt"]) %>%
    select(-name) %>%
    rename(name = name_ascii) %>%
    separate("code", c("iso", "lvl.1", "lvl.2"), sep = "\\.", remove = F) %>%
    select(code, iso, lvl.1, lvl.2, name)
  usethis::use_data(country, admin1, admin2, overwrite = T, compress = "xz", version = 3)
  null <- file.remove(result)
}

# functions...

code <- c("cn", "cc2", "cc3", "ac1", "ac1n", "ac2", "ac2n") %>% stats::setNames(seq_along(.), .)

is.int0 <- function(x) identical(x, integer(0))
# is.iso <- function(val) any(toupper(val) == country$iso, na.rm = T)
# is.iso3 <- function(val) any(toupper(val) == country$iso3, na.rm = T)
# is.country <- function(val) any(val == country$name, na.rm = T)
#
# country.letters <- paste(unique(strsplit(paste(country$name, collapse = ""), "")[[1]]), collapse = "")
# country.regex <- paste0("[^", str_replace(country.letters, "-", "\\\\-"), "]")
# country.sanitize <- function(value) str_squish(str_replace_all(value, country.regex, " "))
# sani.country <- country.sanitize.vec <- Vectorize(country.sanitize, c("value"), USE.NAMES = F)

countrify <- function(val, n = 1, max.distance = 0.1)
{
  result <- NA
  val <- toupper(val)
  if (idx <- match(val, country$iso, nomatch = F)) result <- country[[idx, "iso"]]
  else if (idx <- match(val, country$iso3, nomatch = F)) result <- country[[idx, "iso"]]
  else if (idx <- match(val, toupper(country$name), nomatch = F)) result <- country[[idx, "iso"]]
  else
  {
    idx <- agrep(val, country$name, ignore.case = T, max.distance = max.distance)
    if (!is.int0(idx) & length(idx) <= n) result <- country[[idx[[1]], "iso"]]
  }
  result
}

codify.1 <- function(val, cc2 = NA, n = 1, max.distance = 0.1)
{
  result <- NA
  val <- toupper(val)

  df <- admin1
  if (!is.na(cc2)) df <- dplyr::filter(df, iso == cc2)

  if (idx <- match(val, df$lvl.1, nomatch = F)) result <- df[[idx, "code"]]
  else if (idx <- match(val, toupper(df$name), nomatch = F)) result <- df[[idx, "code"]]
  else
  {
    idx <- agrep(val, df$name, ignore.case = T, max.distance = max.distance)
    if (!is.int0(idx) & length(idx) <= n) result <- df[[idx[[1]], "code"]]
  }

  result
}

codify.2 <- function(val, cc2 = NA, ac1 = NA, n = 1, max.distance = 0.1)
{
  result <- NA
  val <- toupper(val)

  df <- admin2
  if (!is.na(cc2)) df <- dplyr::filter(df, iso == cc2)
  if (!is.na(ac1)) df <- dplyr::filter(df, iso == ac1)

  if (idx <- match(val, df$lvl.2, nomatch = F)) result <- df[[idx, "code"]]
  else if (idx <- match(val, toupper(df$name), nomatch = F)) result <- df[[idx, "code"]]
  else
  {
    idx <- agrep(val, df$name, ignore.case = T, max.distance = max.distance)
    if (!is.int0(idx) & length(idx) <= n) result <- df[[idx[[1]], "code"]]
  }

  result
}

process_regx <- function(val, regx, n = 1)
{
  tokens <- stats::setNames(utils::tail(str_match(val, regx$pattern)[1,], -1), regx$names)
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
