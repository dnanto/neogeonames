#' The country data...
#'
#' A dataset containing country information.
#'
#' @format A data frame with 252 rows and 19 variables:
#' \describe{
#'	 \item{iso}{iso}
#'	 \item{iso3}{iso3}
#'	 \item{iso_numeric}{iso_numeric}
#'	 \item{fips}{fips}
#'	 \item{country}{country}
#'	 \item{capital}{capital}
#'	 \item{area}{area}
#'	 \item{population}{population}
#'	 \item{continent}{continent}
#'	 \item{tld}{tld}
#'	 \item{currency_code}{currency_code}
#'	 \item{currency_name}{currency_name}
#'	 \item{phone}{phone}
#'	 \item{postal_code_format}{postal_code_format}
#'	 \item{postal_code_regex}{postal_code_regex}
#'	 \item{languages}{languages}
#'	 \item{geonameid}{geonameid}
#'	 \item{neighbours}{neighbours}
#'	 \item{equivalent_fips_code}{equivalent_fips_code}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/countryInfo.txt}
"country"

#' The geoname data...
#'
#' A dataset containing administrative division 1 data.
#'
#' @format A data frame with 400189 rows and 19 columns
#' \describe{
#'	 \item{geonameid}{geonameid}
#'	 \item{name}{name}
#'	 \item{asciiname}{asciiname}
#'	 \item{alternatenames}{alternatenames}
#'	 \item{latitude}{latitude}
#'	 \item{longitude}{longitude}
#'	 \item{feature_class}{feature_class}
#'	 \item{feature_code}{feature_code}
#'	 \item{country_code}{country_code}
#'	 \item{cc2}{cc2}
#'	 \item{admin1_code}{admin1_code}
#'	 \item{admin2_code}{admin2_code}
#'	 \item{admin3_code}{admin3_code}
#'	 \item{admin4_code}{admin4_code}
#'	 \item{population}{population}
#'	 \item{elevation}{elevation}
#'	 \item{dem}{dem}
#'	 \item{timezone}{timezone}
#'	 \item{modification_date}{modification_date}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/allCountries.zip}
"geoname"
