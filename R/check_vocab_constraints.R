#' @title Check Athena Vocabulary Constraints
#'
#' @description Sometimes there are violations of the NULL and NOT NULL constants of the
#' athena vocabularies. If you are having trouble loading the vocabularies, this
#' might be why. This function will check the vocabularies that have been
#' imported by `extract_vocab()`. The function will write out new vocabularies
#' to the folder specified in `path` if taking `action = "remove_conflicts"`.
#' Otherwise if using `action = "show_conflicts"` only the rows that violate
#' constraints will be written out. In this case, the violations are also
#' returned in memory since there are likely to be a small number.
#'
#' @param vocabulary a list of vocabularies returned from `extract_vocab()`
#' @param path character string of the path to the location where you would like
#'   to send the processed vocabularies
#' @param action character string of either: - "remove_conflicts": removes the
#'   conflicting rows and writes out the data - "show_conflicts": keeps only the
#'   conflicting rows and write out the data
#'
#' @return either `TRUE` or a list of vocabularies containing only violating
#'   rows
#' @export
#' @md
check_vocabulary_constraints <- function(vocabulary,
                                         path,
                                         action = c("remove_conflicts", "show_conflicts")) {

  col_constraints <- list(
    concept = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NULL"),
    concept_ancestor = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL"
    ),
    concept_class = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL"
    ),
    concept_relationship = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NULL"
    ),
    concept_synonym = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL"
    ),
    domain = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL"
    ),
    drug_strength = c(
      "NOT NULL",
      "NOT NULL",
      "NULL",
      "NULL",
      "NULL",
      "NULL",
      "NULL",
      "NULL",
      "NULL",
      "NOT NULL",
      "NOT NULL",
      "NULL"
    ),
    relationship = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NOT NULL"
    ),
    vocabulary = c(
      "NOT NULL",
      "NOT NULL",
      "NOT NULL",
      "NULL",
      "NOT NULL"
    )
  )

  action <- match.arg(action, c("remove_conflicts", "show_conflicts"))

  if (action == "remove_conflicts") {
    vocab <- vocab %>%
      imap(
        ~ filter_at(
          .x,
          .vars = names(.x)[col_constraints[[.y]] == "NOT NULL"],
          .vars_predicate = all_vars(!is.na(.))))

    purrr::iwalk(vocab, .f = ~ readr::write_csv(.x, path = paste0(
      path, .y, ".csv"
    )))

    return(vocab)
  }

  if (action == "show_conflicts") {
    vocab <- vocab %>%
      imap(
        ~ filter_at(
          .x,
          .vars = names(.x)[col_constraints[[.y]] == "NOT NULL"],
          .vars_predicate = any_vars(is.na(.))))

    purrr::iwalk(vocab, .f = ~ readr::write_csv(.x, path = paste0(
      path, .y, ".csv"
    )))

    return(TRUE)
  }
}


#' @title Fix Athena Vocabulary Constraints
#'
#' @description Works like `check_vocabulary_constraints()` but fixes them.
#'
#' @param vocab a list of vocabularies returned from `extract_vocab()`
#'
#' @importFrom dplyr mutate if_else
#'
#' @return a vocab where null concept names are replaced with "No name provided"
#' @export
#' @md
fix_vocabulary_constraints <- function(vocab) {

  vocab[["concept"]] <- vocab[["concept"]] %>%
    dplyr::mutate(
      concept_name = dplyr::if_else(
        is.na(concept_name), "No name provided", concept_name))

  vocab[["concept_synonym"]] <- vocab[["concept_synonym"]] %>%
    dplyr::mutate(
      concept_synonym_name = dplyr::if_else(
        is.na(concept_synonym_name), "No name provided", concept_synonym_name))

  return(vocab)

}


