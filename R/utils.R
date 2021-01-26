transact <- function(connection, query) {
  st <- DBI::dbSendStatement(connection, query)
  check <- DBI::dbHasCompleted(st)
  DBI::dbClearResult(st)
  return(check)
}

write_notify <- function(conn, name, value) {
  DBI::dbWriteTable(conn = conn,
                    name = name, value = value,
                    overwrite = FALSE,
                    append = TRUE,
                    copy = TRUE)
  rlang::inform(paste("Table:", name, "successfully written"))
}

#' Speak Utter Nonsense
#'
#' Loading takes some time. Let's pass the time together.
#'
#' @importFrom rlang inform
#'
#' @return
speak_utter_nonsense <- function() {

  verbs <- sample(c("organising", "sifting", "shuffling", "sorting", "filing"), 1)
  nouns <- sample(c("chickpeas", "marbles", "otters", "washing up", "ice cream"), 1)

  inform(paste(verbs, nouns))

}
