#' @title
#' country
#'
#' @description
#' This is a data frame of the GeoNames Gazetteer country info data.
#'
#' @details
#' CountryCodes:
#'
#' ============
#'
#' The official ISO country code for the United Kingdom is 'GB'. The code 'UK' is reserved.
#'
#' A list of dependent countries is available here:
#' \url{https://spreadsheets.google.com/ccc?key=pJpyPy-J5JSNhe7F_KxwiCA&hl=en}
#'
#'
#' The countrycode XK temporarily stands for Kosvo:
#' \url{http://geonames.wordpress.com/2010/03/08/xk-country-code-for-kosovo/}
#'
#'
#' CS (Serbia and Montenegro) with geonameId = 8505033 no longer exists.
#' AN (the Netherlands Antilles) with geonameId = 8505032 was dissolved on 10 October 2010.
#'
#'
#' Currencies :
#'
#' ============
#'
#' A number of territories are not included in ISO 4217, because their currencies are not per se an independent currency,
#' but a variant of another currency. These currencies are:
#'
#' \enumerate{
#'   \item FO : Faroese krona (1:1 pegged to the Danish krone)
#'   \item GG : Guernsey pound (1:1 pegged to the pound sterling)
#'   \item JE : Jersey pound (1:1 pegged to the pound sterling)
#'   \item IM : Isle of Man pound (1:1 pegged to the pound sterling)
#'   \item TV : Tuvaluan dollar (1:1 pegged to the Australian dollar).
#'   \item CK : Cook Islands dollar (1:1 pegged to the New Zealand dollar).
#' }
#'
#' The following non-ISO codes are, however, sometimes used: GGP for the Guernsey pound,
#' JEP for the Jersey pound and IMP for the Isle of Man pound (\url{http://en.wikipedia.org/wiki/ISO_4217})
#'
#'
#' A list of currency symbols is available here : \url{http://forum.geonames.org/gforum/posts/list/437.page}
#' another list with fractional units is here: \url{http://forum.geonames.org/gforum/posts/list/1961.page}
#'
#'
#' Languages :
#'
#' ===========
#'
#' The column 'languages' lists the languages spoken in a country ordered by the number of speakers. The language code is a 'locale'
#' where any two-letter primary-tag is an ISO-639 language abbreviation and any two-letter initial subtag is an ISO-3166 country code.
#'
#' Example : es-AR is the Spanish variant spoken in Argentina.
#'
#' @format A data frame with 252 rows and 19 variables:
#' \describe{
#'	 \item{iso}{ISO 3166-1 alpha-2}
#'	 \item{iso3}{ISO 3166-1 alpha-3}
#'	 \item{iso_numeric}{ISO 3166-1 numeric}
#'	 \item{fips}{FIPS codes}
#'	 \item{country}{country}
#'	 \item{capital}{capital}
#'	 \item{area}{area in km^2}
#'	 \item{population}{population}
#'	 \item{continent}{continent}
#'	 \item{tld}{top-level domain}
#'	 \item{currency_code}{ISO 4217}
#'	 \item{currency_name}{currency name}
#'	 \item{phone}{calling code}
#'	 \item{postal_code_format}{postal code format}
#'	 \item{postal_code_regex}{postal code regex}
#'	 \item{languages}{ISO 639 + ISO 3166}
#'	 \item{geonameid}{geonameid}
#'	 \item{neighbours}{neighbouring countries}
#'	 \item{equivalent_fips_code}{equivalent fips code}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/countryInfo.txt}
"country"

#' @title
#' geoname
#'
#' @description
#' This is a data frame consisting of a subset of the GeoNames Gazetteer all country data.
#'
#'
#' Feature class:
#'
#' @details
#' \tabular{ll}{
#'   feature_class \tab definition \cr
#'   A \tab country, state, region,... \cr
#'   P \tab city, village,... \cr
#'  }
#'
#' Feature code:
#'
#' \tabular{llll}{
#'   feature_class \tab feature_code \tab definition \tab note \cr
#'   A \tab ADM1 \tab first-order administrative division \tab a primary administrative division of a country, such as a state in the United States \cr
#'   A \tab ADM1H \tab historical first-order administrative division \tab a former first-order administrative division \cr
#'   A \tab ADM2 \tab second-order administrative division \tab a subdivision of a first-order administrative division \cr
#'   A \tab ADM2H \tab historical second-order administrative division \tab a former second-order administrative division \cr
#'   A \tab ADM3 \tab third-order administrative division \tab a subdivision of a second-order administrative division \cr
#'   A \tab ADM3H \tab historical third-order administrative division \tab a former third-order administrative division \cr
#'   A \tab ADM4 \tab fourth-order administrative division \tab a subdivision of a third-order administrative division \cr
#'   A \tab ADM4H \tab historical fourth-order administrative division \tab a former fourth-order administrative division \cr
#'   A \tab PCL \tab political entity \tab  \cr
#'   A \tab PCLD \tab dependent political entity \tab  \cr
#'   A \tab PCLF \tab freely associated state \tab  \cr
#'   A \tab PCLH \tab historical political entity \tab a former political entity \cr
#'   A \tab PCLI \tab independent political entity \tab  \cr
#'   A \tab PCLS \tab semi-independent political entity \tab  \cr
#'   A \tab TERR \tab territory \tab  \cr
#'   P \tab PPLA \tab seat of a first-order administrative division \tab seat of a first-order administrative division (PPLC takes precedence over PPLA) \cr
#'   P \tab PPLA2 \tab seat of a second-order administrative division \tab  \cr
#'   P \tab PPLA3 \tab seat of a third-order administrative division \tab  \cr
#'   P \tab PPLA4 \tab seat of a fourth-order administrative division \tab  \cr
#'   P \tab PPLC \tab capital of a political entity \tab  \cr
#' }
#'
#' @format A data frame with 445722 rows and 19 columns
#' \describe{
#'	 \item{geonameid}{integer id of record in geonames database}
#'	 \item{name}{name of geographical point (utf8) varchar(200)}
#'	 \item{asciiname}{name of geographical point in plain ascii characters, varchar(200)}
#'	 \item{alternatenames}{alternatenames, comma separated, ascii names automatically transliterated, convenience attribute from alternatename table, varchar(10000)}
#'	 \item{latitude}{latitude in decimal degrees (wgs84)}
#'	 \item{longitude}{longitude in decimal degrees (wgs84)}
#'	 \item{feature_class}{see \url{http://www.geonames.org/export/codes.html}, char(1)}
#'	 \item{feature_code}{see \url{http://www.geonames.org/export/codes.html}, varchar(10)}
#'	 \item{country_code}{ISO-3166 2-letter country code, 2 characters}
#'	 \item{cc2}{alternate country codes, comma separated, ISO-3166 2-letter country code, 200 characters}
#'	 \item{admin1_code}{fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)}
#'	 \item{admin2_code}{code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) }
#'	 \item{admin3_code}{code for third level administrative division, varchar(20)}
#'	 \item{admin4_code}{code for fourth level administrative division, varchar(20)}
#'	 \item{population}{bigint (8 byte int) }
#'	 \item{elevation}{in meters, integer}
#'	 \item{dem}{digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30'' (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.}
#'	 \item{timezone}{the iana timezone id (see file \url{http://download.geonames.org/export/dump/timeZones.txt}) varchar(40)}
#'	 \item{modification_date}{date of last modification in yyyy-MM-dd format}
#'   ...
#' }
#' @source \url{http://download.geonames.org/export/dump/allCountries.zip}
"geoname"
