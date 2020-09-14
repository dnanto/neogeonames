#' @title
#' neogeonames_updated
#'
#' @description
#' This is the date when the latest package data download occurred.
"neogeonames_updated"

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
#'   \item{iso}{ISO 3166-1 alpha-2}
#'   \item{iso3}{ISO 3166-1 alpha-3}
#'   \item{iso_numeric}{ISO 3166-1 numeric}
#'   \item{fips}{FIPS codes}
#'   \item{country}{country}
#'   \item{capital}{capital}
#'   \item{area}{area in km^2}
#'   \item{population}{population}
#'   \item{continent}{continent}
#'   \item{tld}{top-level domain}
#'   \item{currency_code}{ISO 4217}
#'   \item{currency_name}{currency name}
#'   \item{phone}{calling code}
#'   \item{postal_code_format}{postal code format}
#'   \item{postal_code_regex}{postal code regex}
#'   \item{languages}{ISO 639 + ISO 3166}
#'   \item{geonameid}{geonameid}
#'   \item{neighbours}{neighbouring countries}
#'   \item{equivalent_fips_code}{equivalent fips code}
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
#'   A \tab country, state, region, ... \cr
#'   P \tab city, village, ... \cr
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
#' @format A data frame with 445818 rows and 12 columns
#' \describe{
#'   \item{geonameid}{integer id of record in geonames database}
#'   \item{name}{name of geographical point (utf8) varchar(200)}
#'   \item{asciiname}{name of geographical point in plain ascii characters, varchar(200)}
#'   \item{latitude}{latitude in decimal degrees (wgs84)}
#'   \item{longitude}{longitude in decimal degrees (wgs84)}
#'   \item{feature_code}{see \url{http://www.geonames.org/export/codes.html}, varchar(10)}
#'   \item{country_code}{ISO-3166 2-letter country code, 2 characters}
#'   \item{admin1_code}{fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)}
#'   \item{admin2_code}{code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) }
#'   \item{admin3_code}{code for third level administrative division, varchar(20)}
#'   \item{admin4_code}{code for fourth level administrative division, varchar(20)}
#'   \item{modification_date}{date of last modification in yyyy-MM-dd format}
#' }
#' @source \url{http://download.geonames.org/export/dump/allCountries.zip}
"geoname"

#' @title
#' alternate
#'
#' @description
#' This is a data frame that maps alternate names to geoname identifiers.
#'
#' @details
#' It is a subset corresponding to the "PCLI", "PCLH", "PCLS", "PCLD", "PCLF", "PCL", and "TERR" feature codes.
#'
#' @format A data frame with 37589 rows and 10 columns
#' \describe{
#'   \item{alternateid}{the id of this alternate name}
#'   \item{geonameid}{geonameId referring to id in table 'geoname'}
#'   \item{isolanguage}{iso 639 language code 2- or 3-characters; 4-characters 'post' for postal codes and 'iata','icao' and faac for airport codes, fr_1793 for French Revolution names, abbr for abbreviation, link to a website (mostly to wikipedia), wkdt for the wikidataid}
#'   \item{alternateName}{alternate name or name variant}
#'   \item{isPreferredName}{if this alternate name is an official/preferred name}
#'   \item{isShortName}{if this is a short name like 'California' for 'State of California'}
#'   \item{isColloquial}{if this alternate name is a colloquial or slang term. Example: 'Big Apple' for 'New York'}
#'   \item{isHistoric}{if this alternate name is historic and was used in the past. Example 'Bombay' for 'Mumbai'}
#'   \item{from}{from period when the name was used}
#'   \item{to}{to period when the name was used}
#' }
#' @source \url{http://download.geonames.org/export/dump/alternateNamesV2.zip}
"alternate"

#' @title
#' language
#'
#' @description
#' This is a data frame of ISO 639 language codes, as used for alternate names in the alternate data frame.
#'
#' @format A data frame with 7929 rows and 4 columns
#' \describe{
#'   \item{iso3}{the ISO 639-3 code}
#'   \item{iso2}{the ISO 639-2 code}
#'   \item{iso1}{the ISO 639-1 code}
#'   \item{name}{the language name}
#' }
#' @source \url{http://download.geonames.org/export/dump/iso-languagecodes.txt}
"language"

#' @title
#' timezone
#'
#' @description
#' This is a data frame of time zone data.
#'
#' @format A data frame with 425 rows and 5 columns
#' \describe{
#'   \item{country}{the country code}
#'   \item{timezone}{the timezone id}
#'   \item{gmt}{the GMT offset on 1st of January}
#'   \item{dst}{the DST offset to gmt on 1st of July (of the current year)}
#'   \item{rawOffset}{the raw offset without DST}
#' }
#' @source \url{http://download.geonames.org/export/dump/timezone.txt}
"timezone"

#' @title
#' shape
#'
#' @description
#' The simplified country boundaries.
#'
#' @format A data frame with 191449 rows and 7 columns
#' \describe{
#'   \item{geonameid}{the geoname identifier}
#'   \item{long}{the longitude}
#'   \item{lat}{the latitude}
#'   \item{order}{the order}
#'   \item{hole}{is hole}
#'   \item{piece}{the piece}
#'   \item{group}{the group id}
#' }
#' @source \url{http://download.geonames.org/export/dump/shapes_simplified_low.json.zip}
"shape"
