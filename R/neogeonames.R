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
  ac0 = c("PCLI", "PCLH", "PCLS", "PCLD", "PCLF", "PCL", "TERR"),
  ac1 = c("ADM1", "ADM1H", "PPLA", "PPLC"),
  ac2 = c("ADM2", "ADM2H", "PPLA2"),
  ac3 = c("ADM3", "ADM3H", "PPLA3"),
  ac4 = c("ADM4", "ADM4H", "PPLA4")
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

#' Calculate the \code{\link{alternate}} row.
#'
#' The function performs a case-insensitive search for matches to the alternate name.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param query The country query.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
unalternatify <- function(query, n = 1, p = list(ignore.case = T)) {
  with(neogeonames::alternate, {
    idx <- NULL
    query <- toupper(query)
    # exact match
    if (idx.m <- match(query, toupper(alternateName), nomatch = F)) {
      idx <- idx.m
    }
    # fuzzy match
    else if (n > 0) {
      idx.m <- do.call(agrep, c(list(query, alternateName), p))
      if (!identical(idx.m, integer(0)) & length(idx.m) <= n) {
        idx <- idx.m[[1]]
      }
    }
    neogeonames::alternate[idx, ]
  })
}

#' Calculate the \code{\link{country}} row.
#'
#' The function performs a case-insensitive search for matches to ISO codes or country name.
#' It also performs a fuzzy search using \code{\link{agrep}} as a fall back.
#'
#' @param query The country query.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
countrify <- function(query, n = 1, p = list(ignore.case = T)) {
  with(neogeonames::country, {
    idx <- NULL

    query <- toupper(query)

    # check ISO 3166-1 alpha-2 code
    if (idx.m <- match(query, toupper(iso), nomatch = F)) {
      idx <- idx.m
    } # check ISO 3166-1 alpha-3 code
    else if (idx.m <- match(query, toupper(iso3), nomatch = F)) {
      idx <- idx.m
    } # check country name
    else if (idx.m <- match(query, toupper(country), nomatch = F)) {
      idx <- idx.m
    } # check alternate name
    else if (nrow(rows <- unalternatify(query, n, p)) > 0) {
      idx <- which(geonameid == rows[[1, "geonameid"]])
    }
    # fuzzy search
    else if (n > 0) {
      idx.m <- do.call(agrep, c(list(query, country), p))
      if (!identical(idx.m, integer(0)) & length(idx.m) <= n) {
        idx <- idx.m[[1]]
      }
    }

    neogeonames::country[idx, ]
  })
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
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{agrep}}
#' @return The rows or \code{data.frame} with 0 rows.
#' @export
geonamify <- function(query, dfgeo = neogeonames::geoname, where = NULL, n = 1, p = list(ignore.case = T)) {
  # where
  for (key in names(where))
  {
    if (nrow(dfgeo) > 0) {
      # in
      dfgeo <- dfgeo[dfgeo[[key]] %in% where[[key]], ]
      # order by (https://stackoverflow.com/a/42605492)
      dfgeo <- dfgeo[order(ordered(dfgeo[[key]], levels = where[[key]])), ]
      # remove non-match
      dfgeo <- dfgeo[!is.na(dfgeo$geonameid), ]
    }
    else {
      break
    }
  }

  # where asciiname
  res <- dfgeo[toupper(dfgeo$asciiname) == toupper(query), ]

  # like asciiname
  if (nrow(res) == 0 && n > 0) {
    idx <- do.call(agrep, c(list(query, dfgeo$asciiname), p))
    res <- if (!identical(idx, integer(0)) && length(idx) <= n) dfgeo[idx, ] else neogeonames::geoname[0, ]
  }

  res
}

#' Calculate an administrative division codes for each token according to hierarchy.
#'
#' This function infers an admin code and geonameid for each token in order from left-to-right.
#'
#' @param tokens The place name query tokens.
#' @param admin The admin codes to search.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{adminify_delim}}
#' @return The list with "id" and "ac" atomic vectors consisting of the geonameid and
#'         administrative class division values or \code{NA} values if missing.
#' @export
adminify_tokens <- function(tokens, admin = akac, n = 1, p = list(ignore.case = T)) {
  dfgeo <- neogeonames::geoname

  geo.ac <- sapply(admin, function(ele) NA)
  geo.id <- sapply(admin, function(ele) NA)

  # countrify
  key <- "ac0"
  if (key %in% names(admin)) {
    for (idx in seq_along(tokens)) {
      rows <- countrify(tokens[idx], n, p = p)
      if (!is.na(geo.ac[[key]] <- rows$iso[1])) {
        geo.id[[key]] <- rows$geonameid[1]
        break
      }
    }
    # subset ac0
    if (!is.na(geo.ac[[key]])) {
      dfgeo <- dfgeo[which(dfgeo$country_code == geo.ac[[key]]), ]
      tokens <- tokens[-idx]
      admin <- admin[names(admin) != key]
    }
  }

  for (key in names(admin)) {
    # params to restrict feature code to admin level
    params <- list(feature_code = akfc[[key]])
    for (idx in seq_along(tokens)) {
      # check if perfect match to admin column
      rows <- dfgeo[which(dfgeo[admin[[key]]] == toupper(tokens[idx])), ]
      val <- rows[[admin[key]]][1]
      # otherwise geonamify using previous results
      if (is.na(val)) {
        rows <- geonamify(tokens[idx], dfgeo, params, n, p)
        val <- rows[[admin[key]]][1]
      }
      if (!is.na(val)) {
        # save
        geo.ac[[key]] <- val
        geo.id[[key]] <- rows$geonameid[1]
        # subset
        dfgeo <- dfgeo[which(dfgeo[[admin[key]]] == geo.ac[[key]]), ]
        # remove token
        tokens <- tokens[-idx]
        break
      }
    }
  }

  list(id = geo.id, ac = geo.ac)
}

#' Calculate administrative division codes using a delimiter.
#'
#' This function rotates the token vector, returning the result with the most results.
#'
#' @param query The place name query.
#' @param delim The delimiter pattern.
#' @param admin The admin codes to search.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{adminify_tokens}}
#' @return The list with "id" and "ac" atomic vectors consisting of the geonameid and
#'         administrative class division values or \code{NA} values if missing.
#' @export
adminify_delim <- function(query, delim = NA, admin = akac, n = 1, p = list(ignore.case = T)) {
  tokens <- query
  if (!is.na(delim)) tokens <- stringr::str_trim(stringr::str_split(query, delim, simplify = T))
  tokens <- Filter(nchar, tokens)
  tokens <- tokens[!is.na(tokens)]

  results <- c()
  imax <- 1
  if (length(tokens) > 1) {
    for (i in seq_along(tokens)) {
      results[[i]] <- adminify_tokens(
        c(utils::tail(tokens, -i), utils::head(tokens, i)), admin, n, p
      )
      size <- length(Filter(Negate(is.na), results[[i]]$id))
      imax <- max(i, imax)
      if (size == length(tokens)) {
        break
      }
    }
  }
  else {
    results[[imax]] <- adminify_tokens(tokens, admin, n, p)
  }

  results[[imax]]
}

#' Calculate administrative division codes using a named regular expression.
#'
#' Only return a result if the all named patterns are found.
#'
#' @param query The place name query.
#' @param regex The list object with a "pattern" and admin code "name" entry. The pattern entry is
#'              a regular expression with groups that correspond to the names in the name vector.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{adminify_regexes}}
#' @return The list with "id" and "ac" atomic vectors consisting of the geonameid and
#'         administrative class division values or \code{NA} values if missing.
#' @export
adminify_regex <- function(query, regex, n = 1, p = list(ignore.case = T)) {
  dfgeo <- neogeonames::geoname

  geo.ac <- sapply(akac, function(ele) NA)
  geo.id <- sapply(akac, function(ele) NA)

  tokens <- stringr::str_match(query, regex$pattern)
  tokens <- stats::setNames(tokens[2:length(tokens)], regex$name)

  if (!any(is.na(tokens))) {
    # countrify
    key <- "ac0"
    if (key %in% names(tokens)) {
      rows <- countrify(tokens[key], n = n, p = p)
      if (!is.na(geo.ac[[key]] <- rows$iso[1])) {
        geo.id[[key]] <- rows$geonameid[1]
        # subset
        dfgeo <- dfgeo[which(dfgeo$country_code == geo.ac[[key]]), ]
      }
    }

    # geonamify
    for (key in setdiff(sort(names(tokens)), "ac0")) {
      # check if perfect match to admin column
      rows <- dfgeo[which(dfgeo[akac[[key]]] == toupper(tokens[key])), ]
      val <- rows[[akac[key]]][1]
      # otherwise geonamify using previous results
      if (is.na(val)) {
        rows <- geonamify(tokens[key], dfgeo, list(feature_code = akfc[[key]]), n = n, p = p)
        val <- rows[[akac[key]]][1]
      }
      if (!is.na(val)) {
        # save
        geo.ac[[key]] <- val
        geo.id[[key]] <- rows$geonameid[1]
        # subset
        dfgeo <- dfgeo[which(dfgeo[[akac[key]]] == geo.ac[[key]]), ]
      }
    }
  }

  list(id = geo.id, ac = geo.ac)
}

#' Calculate administrative division codes using a list of named regular expression.
#'
#' Only return a result if the all named patterns are found.
#'
#' @param query The place name query.
#' @param regexes The list of named regular expressions.
#' @param n The number of allowable fuzzy search results before returning the top result,
#'          otherwise nothing.
#' @param p The parameters for \code{\link{agrep}}.
#' @seealso \code{\link{adminify_regex}}
#' @return The list with "id" and "ac" atomic vectors consisting of the geonameid and
#'         administrative class division values or \code{NA} values if missing.
#' @export
adminify_regexes <- function(query, regexes, n = 1, p = list(ignore.case = T)) {
  result <- lapply(regexes, adminify_regex, query = query, n = n, p = p)
  result[[which.min(lapply(result, function(ele) sum(is.na(ele$id))))]]
}
