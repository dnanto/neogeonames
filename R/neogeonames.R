#' @description
#' neogeonames: New GeoNames Data Package and Functions in R
#'
#' This package provides a subset of GeoNames Gazetteer data and normalization functions.
#'
#' @docType package
#' @name neogeonames
"_PACKAGE"

#' Map admin key to feature codes...
#' @export
akfc <- list(
  ac0 = c("TERR", "PCL", "PCLF", "PCLD", "PCLS", "PCLH", "PCLI"),
  ac1 = c("PPLC", "PPLA", "ADM1H", "ADM1"),
  ac2 = c("PPLA2", "ADM2H", "ADM2"),
  ac3 = c("PPLA3", "ADM3H", "ADM3"),
  ac4 = c("PPLA4", "ADM4H", "ADM4")
)

#' Map admin key to admin column...
#' @export
akac <- c(
  ac0 = "country_code",
  ac1 = "admin1_code",
  ac2 = "admin2_code",
  ac3 = "admin3_code",
  ac4 = "admin4_code"
)

#' Calculate the \code{\link{country}} row.
#'
#' The function performs a case-insensitive search for matches to ISO codes or country name.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param query The country query.
#' @param dfcou The data frame of \code{\link{country}} data.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param ... The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
countrify <- function(query, dfcou = neogeonames::country, n = 1, ...) {
  idx <- NULL

  query <- toupper(query)

  # check ISO 3166-1 alpha-2 code
  if (idx.m <- match(query, toupper(dfcou$iso), nomatch = F)) {
    idx <- idx.m
  } # check ISO 3166-1 alpha-3 code
  else if (idx.m <- match(query, toupper(dfcou$iso3), nomatch = F)) {
    idx <- idx.m
  } # check country name
  else if (idx.m <- match(query, toupper(dfcou$country), nomatch = F)) {
    idx <- idx.m
  } # fuzzy search
  else if (n > 0) {
    idx.m <- agrep(query, dfcou$country, ignore.case = T, ...)
    if (!identical(idx.m, integer(0)) & length(idx.m) <= n) {
      idx <- idx.m[[1]]
    }
  }

  dfcou[idx, ]
}

#' Calculate the \code{\link{geoname}} rows.
#'
#' The function performs a case-insensitive search for matches to the asciiname column.
#'
#' @param query The place name query.
#' @param dfgeo The data frame of \code{\link{geoname}} data.
#' @param where The named vector of values analogous to the SQL "WHERE" clause.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise return nothing if exceeded.
#' @param ... The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
geonamify <- function(query, dfgeo = neogeonames::geoname, where = NULL, n = 1, ...) {
  # where asciiname
  dfgeo <- dfgeo[toupper(dfgeo$asciiname) == toupper(query), ]

  # like asciiname
  if (nrow(dfgeo) == 0 && n > 0) {
    idx <- agrep(query, dfgeo$asciiname, ignore.case = T, ...)
    if (!identical(idx, integer(0)) & length(idx) <= n) {
      dfgeo <- dfgeo[idx[[1]], ]
    }
  }

  # where
  for (key in names(where))
  {
    if (nrow(dfgeo) > 0) {
      # in
      dfgeo <- dfgeo[dfgeo[[key]] %in% where[[key]], ]
      # order by
      dfgeo <- dfgeo[match(where[[key]], dfgeo[[key]]), ]
      # remove non-match
      dfgeo <- dfgeo[!is.na(dfgeo$geonameid), ]
    }
    else {
      break
    }
  }

  dfgeo
}

#' Calculate administrative division codes by splitting on a delimiter pattern.
#'
#' This function infers an admin code and geonameid for each token.
#'
#' @param query The place name query.
#' @param delim The delimiter pattern.
#' @param dfgeo The data frame of \code{\link{geoname}} data.
#' @param dfcou The data frame of \code{\link{country}} data.
#' @param ... The arguments passed to \code{\link{countrify}} and \code{\link{geonamify}}.
#' @seealso \code{\link{geonamify}}
#' @return The list with "id" and "ac" atomic vectors consisting of the geonameid and
#'         administrative class division values or \code{NA} values if missing.
#' @export
adminify <- function(query, delim, dfgeo = neogeonames::geoname, dfcou = neogeonames::country, ...) {
  geo.ac <- sapply(akac, function(ele) NA)
  geo.id <- sapply(akac, function(ele) NA)
  tokens <- stringr::str_trim(stringr::str_split(query, delim, simplify = T))
  tokens <- Filter(nchar, tokens)
  tokens <- tokens[!is.na(tokens)]

  # countrify
  for (idx in seq_along(tokens))
  {
    rows <- countrify(tokens[idx], dfcou = dfcou, ...)
    if (!is.na(geo.ac[["ac0"]] <- rows$iso[1])) {
      geo.id[["ac0"]] <- rows$geonameid[1]
      break
    }
  }

  # subset ac0
  if (!is.na(geo.ac[["ac0"]])) dfgeo <- dfgeo[which(dfgeo$country_code == geo.ac[["ac0"]]), ]

  keys <- geo.ac[(1 + !is.na(geo.ac[["ac0"]])):length(geo.ac)]

  for (key in names(keys))
  {
    # params to restrict feature code to admin level
    params <- list(feature_code = akfc[[key]])
    for (idx in seq_along(tokens))
    {
      # check if perfect match to admin column
      rows <- dfgeo[which(dfgeo[akac[[key]]] == toupper(tokens[idx])), ]
      val <- rows[[akac[key]]][1]
      # otherwise geonamify using previous results
      if (is.na(val)) {
        rows <- geonamify(tokens[idx], dfgeo, params, ...)
        val <- rows[[akac[key]]][1]
      }
      if (!is.na(val)) {
        # save
        geo.ac[[key]] <- val
        geo.id[[key]] <- rows$geonameid[1]
        # subset
        dfgeo <- dfgeo[which(dfgeo[[akac[key]]] == geo.ac[[key]]), ]
        # remove token
        tokens <- tokens[-idx]
        break
      }
    }
  }

  list(id = geo.id, ac = geo.ac)
}
