#' @description
#' neogeonames: Parse, Sniff, and Normalize Place Names in R
#'
#' This package provides a subset of GeoNames Gazetteer data and normalization functions.
#'
#' @docType package
#' @name neogeonames
"_PACKAGE"

#' Map admin key to feature codes...
rcode <- list(
  ac0 = c("TERR", "PCL", "PCLF", "PCLD", "PCLS", "PCLH", "PCLI"),
  ac1 = c("PPLC", "PPLA", "ADM1H", "ADM1"),
  ac2 = c("PPLA2", "ADM2H", "ADM2"),
  ac3 = c("PPLA3", "ADM3H", "ADM3"),
  ac4 = c("PPLA4", "ADM4H", "ADM4")
)

#' Map admin key to admin column...
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
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param ... The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
countrify <- function(query, n = 1, ...)
{
  idx <- NULL

  query <- toupper(query)

  # check ISO 3166-1 alpha-2 code
  if (idx.m <- match(query, toupper(neogeonames::country$iso), nomatch = F))
    idx <- idx.m
  # check ISO 3166-1 alpha-3 code
  else if (idx.m <- match(query, toupper(neogeonames::country$iso3), nomatch = F))
    idx <- idx.m
  # check country name
  else if (idx.m <- match(query, toupper(neogeonames::country$country), nomatch = F))
    idx <- idx.m
  # fuzzy search
  else
  {
    idx.m <- agrep(query, neogeonames::country$country, ignore.case = T, ...)
    if (!identical(idx.m, integer(0)) & length(idx.m) <= n)
      idx <- idx.m[[1]]
  }

  neogeonames::country[idx, ]
}

#' Calculate the corresponding \code{\link{geoname}} rows for the asciiname query.
#'
#' @param query The query.
#' @param df The data frame of \code{\link{geoname}} data.
#' @param where The named vector of values analogous to the SQL "WHERE" clause.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise return nothing if exceeded.
#' @param ... The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
geonamify <- function(query, df = neogeonames::geoname, where = NULL, n = 1, ...)
{
  # where asciiname
  df <- df[toupper(df$asciiname) == toupper(query), ]

  # like asciiname
  if (nrow(df) == 0 && n > 0)
  {
    idx <- agrep(query, df$asciiname, ignore.case = T, ...)
    if (!identical(idx, integer(0)) & length(idx) <= n)
      df <- df[idx[[1]], ]
  }

  # where
  if (!is.null(where))
  {
    for (key in names(where))
    {
      if (nrow(df) > 0)
      {
        # in
        df <- df[df[[key]] %in% where[[key]], ]
        # order by
        df <- df[match(where[[key]], df[[key]]), ]
        # remove non-match
        df <- df[!is.na(df$geonameid), ]
      }
      else
      {
        break
      }
    }
  }

  df
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
geonamify_delim <- function(query, delim, ...)
{
  result <- sapply(ccode, function(ele) NA)
  tokens <- stringr::str_trim(stringr::str_split(query, delim, simplify = T))
  tokens <- Filter(nchar, tokens)
  tokens <- tokens[!is.na(tokens)]

  # countrify
  for (idx in seq_along(tokens))
    if (!is.na(result[["ac0"]] <- countrify(tokens[idx], ...)$iso[1]))
      break

  # select table
  df <- neogeonames::geoname
  if (!is.na(result[["ac0"]])) df <- df[which(df$country_code == result[["ac0"]]), ]

  for (key in names(Filter(is.na, result)))
  {
    params <- list(feature_code = rcode[[key]])
    for (idx in seq_along(tokens))
    {
      row <- geonamify(tokens[idx], df, params, ...)[[ccode[key]]][1]
      if (!is.na(row))
      {
        result[[key]] <- row
        df <- df[which(df[[ccode[key]]] == row), ]
        tokens <- tokens[-idx]
        break
      }
    }
  }

  result
}
