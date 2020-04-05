#' @description
#' lubricity: Sniff and Normalize Place Names in R
#'
#' This package provides functions to extract and normalize place names according to administrative division.
#'
#' @docType package
#' @name lubricity
#' @importFrom dplyr %>%
"_PACKAGE"

#' Download the raw data from GeoNames Gazetteer.
#'
#' Download the countryInfo.txt, admin1CodesASCII.txt, and admin2Codes.txt files.
#'
#' @param root The root directory to download the files to.
#' @param url The base url to download the files from.
#' @return Returns a character vector of the downloaded paths named by the file name.
#' @export
geonames_download <- function(root = getwd(), url = "http://download.geonames.org/export/dump")
{
  c("countryInfo.txt", "admin1CodesASCII.txt", "admin2Codes.txt") %>%
    sapply(function(target) {
      dest <- file.path(root, target)
      utils::download.file(file.path(url, target), dest)
      dest
    })
}

#' Read the raw data from the country text file.
#' @param path The path to the file.
#' @return The data frame.
#' @export
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

#' Read the raw data from the level 1 admin code text file.
#' @param path The path to the file.
#' @return The data frame.
#' @export
geonames_read_admin_1 <- function(path)
{
  read_tsv(path, col_names = c("code", "name", "name_ascii", "geonameid"), col_types = "ccci")
}

#' Read the raw data from the level 2 admin code text file.
#' @param path The path to the file.
#' @return The data frame.
#' @export
geonames_read_admin_2 <- function(path)
{
  read_tsv(path, col_names = c("code", "name", "name_ascii", "geonameid"), col_types = "ccci")
}

#' Download and install the GeoNames Gazetteer data.
#' @param url The base url to download the files from.
#' @return The data frame.
#' @export
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

code <- c("cn", "cc2", "cc3", "ac1", "ac1n", "ac2", "ac2n")
code <- stats::setNames(seq_along(code), code)

#' Helper function to test for equivalency to 0.
#' @param val The value to test.
#' @return The boolean result.
#' @export
is.int0 <- function(val) identical(val, integer(0))
# is.iso <- function(val) any(toupper(val) == country$iso, na.rm = T)
# is.iso3 <- function(val) any(toupper(val) == country$iso3, na.rm = T)
# is.country <- function(val) any(val == country$name, na.rm = T)
# country.letters <- paste(unique(strsplit(paste(country$name, collapse = ""), "")[[1]]), collapse = "")
# country.regex <- paste0("[^", str_replace(country.letters, "-", "\\\\-"), "]")
# country.sanitize <- function(value) str_squish(str_replace_all(value, country.regex, " "))
# sani.country <- country.sanitize.vec <- Vectorize(country.sanitize, c("value"), USE.NAMES = F)

#' Calculate the corresponding ISO 3166-1 alpha-2 code for the given query..
#'
#' The function performs a case-insensitive search for an exact match to the country name or ISO codes.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param val The country name query.
#' @param n The number of allowable fuzzy search results before returning the top result, otherwise return nothing if exceeded.
#' @param ... The arguments for \code{\link{agrep}}.
#' @return The ISO 3166-1 alpha-2 code or \code{NA}.
#' @export
countrify <- function(val, n = 1, ...)
{
  result <- NA
  val <- toupper(val)
  if (idx <- match(val, country$iso, nomatch = F)) result <- country[[idx, "iso"]]
  else if (idx <- match(val, country$iso3, nomatch = F)) result <- country[[idx, "iso"]]
  else if (idx <- match(val, toupper(country$name), nomatch = F)) result <- country[[idx, "iso"]]
  else
  {
    idx <- agrep(val, country$name, ignore.case = T, ...)
    if (!is.int0(idx) & length(idx) <= n) result <- country[[idx[[1]], "iso"]]
  }
  result
}

#' Calculate the corresponding level 1 admin code for the given query.
#'
#' The function performs a case-insensitive search for an exact match to the country name or ISO codes.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param val The query, which corresponds to the level of a state (in the United States for example).
#' @param cc2 The ISO 3166-1 alpha-2 code to limit the query.
#' @param n The number of allowable fuzzy search results before returning the top result, otherwise return nothing if exceeded.
#' @param ... The arguments for \code{\link{agrep}}.
#' @return The level 1 admin code or \code{NA}.
#' @export
codify.1 <- function(val, cc2 = NA, n = 1, ...)
{
  result <- NA
  val <- toupper(val)

  df <- admin1
  if (!is.na(cc2)) df <- dplyr::filter(df, iso == cc2)

  if (idx <- match(val, df$lvl.1, nomatch = F)) result <- df[[idx, "code"]]
  else if (idx <- match(val, toupper(df$name), nomatch = F)) result <- df[[idx, "code"]]
  else
  {
    idx <- agrep(val, df$name, ignore.case = T, ...)
    if (!is.int0(idx) & length(idx) <= n) result <- df[[idx[[1]], "code"]]
  }

  result
}

#' Calculate the corresponding level 2 admin code for the given query.
#'
#' The function performs a case-insensitive search for an exact match to the country name or ISO codes.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param val The query, which corresponds to the level of a state (in the United States for example).
#' @param cc2 The ISO 3166-1 alpha-2 code to limit the query.
#' @param ac1 The level 1 admin code to limit the query.
#' @param n The number of allowable fuzzy search results before returning the top result, otherwise return nothing if exceeded.
#' @param ... The arguments for \code{\link{agrep}}.
#' @return The level 2 admin code or \code{NA}.
#' @export
codify.2 <- function(val, cc2 = NA, ac1 = NA, n = 1, ...)
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
    idx <- agrep(val, df$name, ignore.case = T, ...)
    if (!is.int0(idx) & length(idx) <= n) result <- df[[idx[[1]], "code"]]
  }

  result
}

#' Calculate administrative division codes using a named regular expression.
#'
#' The regular expression names each group by the administrative division code.
#' The function processes each group according to the division hierarchy, starting at the top.
#' The function uses matches to higher levels as limiters if lower admin code groups are present in the regular expression.
#' The admin code names include "cn", "ac2", and "ac2" corresponding to "country name", "admin code 1", and "admin code 2".
#'
#' @param val The query value.
#' @param regx The list object with a "pattern" and admin code "name" entry.
#' @param ... The arguments passed to \code{\link{countrify}}, \code{\link{codify.1}}, and \code{\link{codify.2}}.
#' @return The list of extracted admin code names or \code{NA} for each name not found.
#' @export
process_regx <- function(val, regx, ...)
{
  tokens <- stats::setNames(utils::tail(str_match(val, regx$pattern)[1,], -1), regx$name)
  result <- list(cn = NA, ac1 = NA, ac2 = NA)

  if (!any(is.na(tokens)))
  {
    # process admin code hierarchy
    for (name in names(sort(code[regx$name])))
    {
      if (name == "cn")
      {
        result[[name]] <- countrify(tokens[[name]], ...)
      }
      else if (name == "ac1")
      {
        result[[name]] <- codify.1(tokens[[name]], cc2 = result$cn, ...)
      }
      else if (name == "ac2")
      {
        result[[name]] <- codify.2(tokens[[name]], cc2 = result$cn, ac1 = result$ac1, ...)
      }
    }
  }

  result
}

#' Calculate administrative division codes using a list of named regular expression lists.
#'
#' This function essentially runs \code{process_regx} with each regular expression on the value.
#' This function also discards results with incorrectly inferred hierarchy.
#'
#' @param val The query value.
#' @param regx_list The list of named regular expression list objects.
#' @param ... The arguments passed to \code{\link{countrify}}, \code{\link{codify.1}}, and \code{\link{codify.2}}.
#' @seealso \code{\link{process_regx}}
#' @return The list of extracted admin code names or \code{NA} for each name not found.
#' @export
process_regx_list <- function(val, regx_list, ...)
{
  result <- coalesce(!!!lapply(regx_list, process_regx, val = val, ... = ...))
  if(!startsWith(result$ac1, result$cn)) result$ac1 <- NA
  if(!startsWith(result$ac2, result$ac1)) result$ac2 <- NA
  result
}
