#' @description
#' lubricity: Sniff and Normalize Place Names in R
#'
#' This package provides a subset of GeoNames Gazetteer data and normalization functions.
#'
#' @docType package
#' @name lubricity
"_PACKAGE"

#' Feature codes.
#' @export
fcode <- c(
  "ADM1", "ADM1H", "ADM2", "ADM2H", "ADM3", "ADM3H", "ADM4", "ADM4H",
  "PCLD", "PCLF", "TERR",
  "PPLA", "PPLA2", "PPLA3", "PPLA4", "PPLC", "PPLCH"
)

#' Named regex code to feature admin code.
#' @export
rcode <- c(
  ac1 = "ADM1",
  ac2 = "ADM2",
  ac3 = "ADM3",
  ac4 = "ADM4"
)

#' Named regex code to admin column code.
#' @export
ccode <- c(
  ac0 = "country_code",
  ac1 = "admin1_code",
  ac2 = "admin2_code",
  ac3 = "admin3_code",
  ac4 = "admin4_code"
)

#' Calculate the corresponding row in the country table for the given query.
#'
#' The function performs a case-insensitive search for matches to ISO codes or country name.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param query The country name query.
#' @param n The number of allowable fuzzy search results before returning the top result, otherwise nothing.
#' @param ... The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
countrify <- function(query, n = 1, ...)
{
  idx <- NULL

  query <- toupper(query)

  # check ISO 3166-1 alpha-2 code
  if (idx.m <- match(query, toupper(lubricity::country$iso), nomatch = F))
    idx <- idx.m
  # check ISO 3166-1 alpha-3 code
  else if (idx.m <- match(query, toupper(lubricity::country$iso3), nomatch = F))
    idx <- idx.m
  # check country name
  else if (idx.m <- match(query, toupper(lubricity::country$country), nomatch = F))
    idx <- idx.m
  # fuzzy search
  else
  {
    idx.m <- agrep(query, lubricity::country$country, ignore.case = T, ...)
    if (!identical(idx.m, integer(0)) & length(idx.m) <= n)
      idx <- idx.m[[1]]
  }

  lubricity::country[idx, ]
}

#' Calculate the corresponding \code{\link{geoname}} rows for the asciiname query.
#'
#' @param query The query.
#' @param where The named vector of values analogous to the SQL "WHERE" clause.
#' @param n The number of allowable fuzzy search results before returning the top result, otherwise return nothing if exceeded.
#' @param ... The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
geonamify <- function(query, where = NULL, n = 1, ...)
{
  query <- toupper(query)

  # select table
  df <- lubricity::geoname

  # where ...
  if (!is.null(where))
    for (key in names(where))
      if (nrow(df) > 0)
        df <- df[which(df[key] == where[key]), ]

  # where asciiname
  df.x <- df[toupper(df$asciiname) == query, ]

  # asciiname like ...
  if (nrow(df.x) == 0)
  {
    idx <- agrep(query, df$asciiname, ignore.case = T, ...)
    if (!identical(idx, integer(0)) & length(idx) <= n)
      df.x <- df[idx[[1]], ]
  }

  df.x
}

#' Calculate administrative division codes by splitting on a delimiter pattern.
#'
#' This function infers an admin code for each token.
#'
#' @param query The query.
#' @param delim The delimiter pattern.
#' @param ... The arguments passed to \code{\link{countrify}} and \code{\link{geonamify}}.
#' @seealso \code{\link{geonamify}}
#' @return The list of extracted admin code names or \code{NA} for each name not found.
#' @export
adminify_delim <- function(query, delim, ...)
{
  result <- sapply(ccode, function(ele) NA)
  tokens <- stringr::str_trim(stringr::str_split(query, delim, simplify = T))
  tokens <- Filter(nchar, tokens)
  tokens <- tokens[!is.na(tokens)]

  # countrify
  idx <- 0
  for (idx in seq_along(tokens))
  {
    if (!identical(ele <- countrify(tokens[idx], ...)$iso, character(0)))
    {
      result[["ac0"]] <- ele
      break
    }
  }

  # remove identified token
  if (!is.null(idx) && idx > 0)
    tokens <- tokens[-idx]

  # geonamify
  for (key in names(rcode))
  {
    if (is.na(result[[key]]))
    {
      idx <- 0
      for (idx in seq_along(tokens))
      {
        params <- c(feature_code = rcode[[key]], Filter(length, stats::setNames(result, ccode)))
        params <- Filter(Negate(is.na), params)
        ele <- geonamify(tokens[idx], params, ...)[[ccode[key]]]
        if (!identical(ele, character(0)))
          result[[key]] <- ele
      }
      # remove identified token
      if (!is.null(idx) && idx > 0)
        tokens <- tokens[-idx]
    }
  }

  result
}

#' Calculate administrative division codes using a named regular expression.
#'
#' The regular expression names each group by the administrative division code.
#' The function processes each group according to the division hierarchy, starting at the top.
#' The function uses matches to higher levels as limiters if lower admin code groups are present in the regular expression.
#' The admin code names include "cc2", "ac2", and "ac2" corresponding to "country name", "admin code 1", and "admin code 2".
#'
#' @param query The query.
#' @param regex The list object with a "pattern" and admin code "name" entry.
#' @param ... The arguments passed to \code{\link{countrify}} and \code{\link{geonamify}}.
#' @seealso \code{\link{agrep}}, \code{\link{countrify}}, \code{\link{geonamify}}
#' @return The list of extracted admin code names or \code{NULL} for each name not found.
#' @export
adminify_regex <- function(query, regex, ...)
{
  result <- lapply(ccode, function(ele) NULL)
  tokens <- stringr::str_match(query, regex$pattern)
  tokens <- as.list(stats::setNames(tokens[2:length(tokens)], regex$name))
  # process admin code hierarchy
  if (!any(is.na(tokens)))
    for (name in sort(names(tokens)))
      result[[name]] <- (
        if (name == "ac0")
          countrify(tokens[[name]], ...)$iso
        else
          geonamify(
            tokens[[name]],
            c(feature_code = rcode[[name]], Filter(length, stats::setNames(result, ccode))),
            ...
          )[[ccode[name]]]
      )

  replace(result, sapply(result, identical, character(0)), list(NULL))
}

#' Calculate administrative division codes using a list of named regular expression lists.
#'
#' This function essentially runs \code{adminify_regex} with each regular expression on the value.
#'
#' @param query The query.
#' @param regexes The list of named regular expression list objects.
#' @param ... The arguments passed to \code{\link{countrify}} and \code{\link{geonamify}}.
#' @seealso \code{\link{adminify_regex}}
#' @return The list of extracted admin code names or \code{NA} for each name not found.
#' @export
adminify_regexes <- function(query, regexes, ...)
{
  lapply(regexes, adminify_regex, query = query, ...)
}
