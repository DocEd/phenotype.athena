#' Check Available Vocabularies
#'
#' @param connection a database connection to a valid OMOP database
#'
#' @importFrom dplyr tbl collect select pull
#'
#' @return a list of available vocabularies
#' @export
available_vocabularies <- function(connection) {

  tbl(connection, "vocabulary") %>%
    collect() %>%
    dplyr::select(vocabulary_id) %>%
    dplyr::pull() %>%
    sort()

}


#' Convert Non-Standard Vocabulary to Athena Standard
#'
#' clinical concepts should be presented as "standard" concepts in OMOP. This
#' function takes non-standard codes, and returns their standard counterparts.
#'
#' @param connection a database connection to a valid OMOP database
#' @param concept_codes the concept codes you want to phenotype from the source
#'   vocabulary specified in `source_vocabulary`
#' @param source_vocabulary character string of the source vocabulary you are
#'   supplying
#'
#' @importFrom dplyr tbl filter select left_join collect
#' @importFrom rlang .data !!
#' @importFrom magrittr %>%
#'
#' @return a table with the standard representations for the non-standard codes
#' @export
#' @md
convert_to_standard <- function(connection,
                                concept_codes = diabetes$icd_10_code,
                                source_vocabulary = "ICD10") {

  tbl(connection, "concept") %>%
    filter(
      .data$vocabulary_id == source_vocabulary,
      .data$concept_code %in% !! concept_codes) %>%
    select(.data$concept_id) %>%
    left_join(
      tbl(ctn, "concept_relationship"),
      by = c("concept_id" = "concept_id_1")
    ) %>%
    filter(relationship_id == "Maps to") %>%
    select(concept_id = .data$concept_id_2) %>%
    left_join(tbl(connection, "concept"), by = "concept_id") %>%
    collect()

}

#' Create an Athena based phenotype
#'
#' Uses the Athena vocabularies to create a broad phenotype from any other
#' available vocabulary. The behaviour can be modified to limit the returning
#' vocabularies should it be desirable.
#'
#' @param connection a database connection to a valid OMOP database
#' @param concept_codes the concept codes you want to phenotype from the source
#'   vocabulary specified in `source_vocabulary`
#' @param source_vocabulary character vector (length 1) of the source vocabulary you are
#'   supplying
#' @param output_vocabularies character vector (length n) listing the output
#' vocabularies for the phenotype. The default is "everything" which rather
#' unsurpringly returns everything
#'
#' @importFrom dplyr tbl filter select left_join collect
#' @importFrom rlang .data !!
#' @importFrom magrittr %>%
#'
#' @return a table with concept ids that relate to the input codes
#' @export
#' @md
phenotype_athena <- function(connection,
                             concept_codes = diabetes$icd_10_code,
                             source_vocabulary = "ICD10",
                             output_vocabularies = "everything") {

  ## First find whatever the standard mapping in Athena is

  df <- tbl(connection, "concept") %>%
    filter(
      .data$vocabulary_id == source_vocabulary,
      .data$concept_code %in% !! concept_codes) %>%
    select(.data$concept_id) %>%
    left_join(
      tbl(ctn, "concept_relationship"),
      by = c("concept_id" = "concept_id_1")
    ) %>%
    filter(relationship_id == "Maps to") %>%
    select(concept_id_1 = .data$concept_id_2) %>%
    left_join(
      tbl(connection, "concept_relationship"),
      by = "concept_id_1") %>%
    filter(.data$relationship_id == "Mapped from") %>%
    select(concept_id = .data$concept_id_2) %>%
    left_join(tbl(connection, "concept"), by = "concept_id") %>%
    collect()

  if (output_vocabularies == "everything") {
   return(df)
  } else {
    df %>%
      filter(.data$vocabulary_id %in% output_vocabularies)
  }

}

#' Find Descendent Concepts
#'
#' Takes standard athena codes and returns any potential descendent terms (also
#' in standard form) government by the number of levels provided to `depth`
#'
#' @param connection a database connection to a valid OMOP databse
#' @param concept_ids a list of standard athena ids.
#' @param depth integer vector (length 1) the number of descendent levels to
#'   traverse
#'
#' @return
#' @export
find_descendents <- function(connection, concept_ids, depth) {

  tbl(connection, "concept_ancestor") %>%
    filter(
      .data$ancestor_concept_id %in% concept_ids,
      .data$max_levels_of_separation == depth) %>%
    select(concept_id = .data$descendant_concept_id) %>%
    dplyr::distinct(.data$concept_id) %>%
    left_join(tbl(connection, "concept"), by = "concept_id") %>%
    collect()

}

