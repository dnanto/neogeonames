#' Country data...
#'
#' A dataset containing country information.
#'
#' @format A data frame with 252 rows and 3 variables:
#' \describe{
#'   \item{iso}{ISO 3166-1 alpha-2 code}
#'   \item{iso3}{ISO 3166-1 alpha-3 code}
#'   \item{name}{name}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/countryInfo.txt}
"country"

#' Administrative division 1 data...
#'
#' A dataset containing administrative division 1 data.
#'
#' @format A data frame with 3956 rows and 4 variables:
#' \describe{
#'   \item{code}{concatenated admin code}
#'   \item{iso}{ISO 3166-1 alpha-2 code}
#'   \item{lvl.1}{level 1 admin subdivision code}
#'   \item{name}{name}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/admin1CodesASCII.txt}
"admin1"

#' Administrative division 2 data...
#'
#' A dataset containing administrative division 2 data.
#'
#' @format A data frame with 44737 rows and 5 variables:
#' \describe{
#'   \item{code}{concatenated admin code}
#'   \item{iso}{ISO 3166-1 alpha-2 code}
#'   \item{lvl.1}{level 1 admin subdivision code}
#'   \item{lvl.2}{level 2 admin subdivision code}
#'   \item{name}{name}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/admin2Codes.txt}
"admin2"
