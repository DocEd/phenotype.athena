#' Extract OMOP Vocabularies from Source CSV Files
#'
#' Takes a single argument `vocabulary_path` which is the local path
#' to the OMOP vocabularies in CSV format. These are an essential component to
#' create a new OMOP database
#'
#' @param vocabulary_path character string containing the path to the folder
#'   containing OMOP vocabularies as CSV.
#'   removes them before attempting to write to the database
#' @importFrom dplyr filter_at all_vars
#' @importFrom purrr imap map2
#' @importFrom readr cols read_delim col_integer col_double col_character col_date
#' @importFrom stringr str_sub
#'
#' @return a list of tables containing the vocabularies
#' @export
#' @md
extract_vocab <- function(vocabulary_path) {

  # Identify Files
  csvs <- list.files(vocabulary_path)

  # Select out CSVs and convert to file paths
  csvs <- csvs[grepl("\\.csv$", csvs)]
  fnames <- tolower(gsub(".csv", "", csvs))

  csvs <- file.path(vocabulary_path, csvs)


  ## This was frustratingly difficult to do programatically, due to the
  ## way in which you specify column types in readr. I officially give up.
  ## If anyone makes it here and can offer a better alternative, I'm all ears.

  col_specs <- list(
    concept = cols(
      col_integer(),
      col_character(),
      col_character(),
      col_character(),
      col_character(),
      col_character(),
      col_character(),
      col_date(format = "%Y%m%d"),
      col_date(format = "%Y%m%d"),
      col_character()),
    concept_ancestor = cols(
      col_integer(),
      col_integer(),
      col_integer(),
      col_integer()
    ),
    concept_class = cols(
      col_character(),
      col_character(),
      col_integer()
    ),
    concept_relationship = cols(
      col_integer(),
      col_integer(),
      col_character(),
      col_date(format = "%Y%m%d"),
      col_date(format = "%Y%m%d"),
      col_character()
    ),
    concept_synonym = cols(
      col_integer(),
      col_character(),
      col_integer()
    ),
    domain = cols(
      col_character(),
      col_character(),
      col_integer()
    ),
    drug_strength = cols(
      col_integer(),
      col_integer(),
      col_double(),
      col_integer(),
      col_double(),
      col_integer(),
      col_double(),
      col_integer(),
      col_integer(),
      col_date(format = "%Y%m%d"),
      col_date(format = "%Y%m%d"),
      col_character()
    ),
    relationship = cols(
      col_character(),
      col_character(),
      col_character(),
      col_character(),
      col_character(),
      col_integer()
    ),
    vocabulary = cols(
      col_character(),
      col_character(),
      col_character(),
      col_character(),
      col_integer()
    )
  )

  csvs_import <- csvs[match(names(col_specs), fnames)]

  # Read in
  vocab <- map2(
    .x = csvs_import,
    .y = col_specs,
    .f = ~ read_delim(
      file = .x,
      col_types = .y,
      quote = "",
      delim = "\t",
      progress = TRUE,
      na = "")
  )

  names(vocab) <- names(col_specs)
  return(vocab)
}


#' Prepare Athena Vocabularies for loading into SQLite
#'
#' SQLite does not have native types for dates or times. Rather is can only
#' support text, floating points, integers and blobs. As a result, it is
#' referable to convert all dates and times into text before loading, to ensure
#' that the date representation is in a human readable format.
#' Functions to efficiently parse these data are part of the core SQLite code
#' base.
#'
#' @param vocab a list of vocabularies returned from `extract_vocab()`
#'
#' @importFrom purrr modify_at
#' @importFrom dplyr mutate_if
#' @importFrom lubridate is.Date
#' @importFrom magrittr %>%
#'
#' @return
#' @export
#'
#' @examples
#' @md
prep_sqlite_vocabularies <- function(vocab) {

  vocab %>%
    purrr::modify_at(
      .at = c("concept", "concept_relationship", "drug_strength"),
      .f = function(tbl) {
        mutate_if(tbl, lubridate::is.Date, ~ format(.x, "%Y-%m-%d"))
    })

}

