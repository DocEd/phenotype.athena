#' @title Create an empty OMOP database
#'
#' @description At the moment, this just creates the Athena vocabularies. Can
#'   easily add functionality to write out the clinical tables if necessary.
#'   This function instantiates an OHDSI CDM (referred to throughout as OMOP for
#'   brevity) database from the standardised vocabularies. It can be specified
#'   to output either version 5.3.1 or 6.0.0. After the OMOP database has been
#'   created, you have the option to add clinical data directly.
#'
#' @param project_path the path to your project folder with the following
#'   populated folders: \itemize{\item `vocab`: contains ATHENA vocabularies. }
#' @param cdm_version the version of the CDM you are using, choose from:
#'   \itemize{ \item "5.3.1" \item "6.0.0" }
#' @param vocabulary_version the version of the vocabulary you are using
#' @param database_name the name of the database you are connecting to. In the
#'   case of using SQLite, this is the file path to the database.
#' @param database_schema the schema name of the target database. Defaults to "public".
#' @param database_engine the database engine, choose from:
#'   - sqlite
#'   - postgres
#' @param host_name host ip address
#' @param port_no port number
#' @param username username to database (*must* have write privileges)
#' @param indexes logical: do you want to apply indexes?
#' @param constraints logical: do you want to apply relational constraints?
#' @param vocabulary  logical: do you want to write out vocabularies?
#'
#' @importFrom DBI dbConnect dbDisconnect dbListTables
#' @importFrom dplyr collect tbl filter
#' @importFrom glue glue
#' @importFrom magrittr extract extract2 set_names %>%
#' @importFrom purrr iwalk imap map_lgl
#' @importFrom readr read_file read_lines
#' @importFrom rlang inform abort
#' @importFrom rstudioapi askForPassword
#' @importFrom RPostgres Postgres
#' @importFrom RSQLite SQLite
#' @importFrom stringr str_extract_all str_subset
#'
#' @return `TRUE` if completed without errors and writing to database
#' @export
#' @md
stand_up_omop <- function(project_path,
                          cdm_version =  c("5.3.1", "6.0.0"),
                          vocabulary_version = "5",
                          database_name = NULL,
                          database_schema = "public",
                          database_engine = c("sqlite", "postgres"),
                          host_name = "localhost",
                          port_no = 5432,
                          username = NULL,
                          vocabulary = TRUE,
                          indexes = TRUE,
                          constraints = TRUE) {

  fstart <- Sys.time()

  if (!(any(c("5.3.1", "6.0.0") == cdm_version))) {
    rlang::abort(glue("{cdm_version} is not a valid choice"))
  }

  cdm_version <- match.arg(cdm_version, c("5.3.1", "6.0.0"))
  cdm_version <- gsub("\\.", "_", cdm_version)

  database_engine <- match.arg(database_engine, c("sqlite", "postgres"))

  if (all(!(database_engine %in% c("sqlite", "postgres")))) {
    rlang::abort(
      glue("{database_engine} is not a valid choice of database")
    )
  }

  if (database_engine == "postgres") {
    abort("Postgres has not yet been finalised.")
  }

  if (cdm_version == "6_0_0") {
    abort("Version 6 has not yet been finalised.")
  }

  # Check initial project folder structure
  project_dirs <- list.dirs(project_path, full.names = FALSE)
  if (!("vocab" %in% project_dirs)) {
    rlang::abort("Your project folder structure is not correct, please include the athena vocabularies")
  }

  rlang::inform("Attempting to connect to database")

  if (database_engine == "postgres") {

    ctn <- DBI::dbConnect(
      RPostgres::Postgres(),
      host = host_name,
      port = port_no,
      user = username,
      password = askForPassword("Please enter your password"),
      dbname = database_name
    )

  } else {

    ctn <- dbConnect(RSQLite::SQLite(), file.path(project_path, database_name))

  }

  inform("Connection established")

  # Confirm database is empty
  tbls <- dbListTables(ctn)
  if (length(tbls) != 0) {
    abort("You should be connecting to an empty database. Try again.")
  }

  ddl_path <- system.file("dll", cdm_version, database_engine, "vocabulary.sql", package = "phenotype.athena")

  # Send create table statements
  # This is for postgres potentially.
  # qrys <- read_file(ddl_path) %>%
  #   str_extract_all("(?s)(?<=CREATE TABLE).*?(?=;)") %>%
  #   extract2(1) %>%
  #   paste0("CREATE TABLE", ., ";")

  qrys <- read_file(ddl_path) %>%
    strsplit(";", ) %>%
    extract2(1) %>%
    paste0(., ";")

  qrys <- qrys[1:(length(qrys)-1)]

  transact(ctn, "BEGIN TRANSACTION;")
  qry_result <- map_lgl(.x = qrys, .f = ~ transact(ctn, .x))

  if (all(qry_result)) {
    inform("Empty tables have been written successfully")
  } else {
    abort("Problem writing out tables to database")
  }

  ## Retrieve tables from the database.
  ## We need the datatypes and structures.
  ## Any content can be ignored
  table_names <- sort(dbListTables(ctn))

  vocabulary_names <- c(
    "attribute_definition",
    "cohort_definition",
    "concept",
    "concept_ancestor",
    "concept_class",
    "concept_relationship",
    "concept_synonym",
    "domain",
    "drug_strength",
    "relationship",
    "source_to_concept_map",
    "vocabulary"
  )

  table_names <- table_names[!(table_names %in% vocabulary_names)]

  # Set up tables according to the CDM Schema
  # Capture tables in list
  inform("Starting CDM build")

  # VOCABULARIES ====

  if (vocabulary) {

    inform("Reading in vocabularies")
    my_vocab <- extract_vocab(file.path(project_path, "vocab"))
    inform("Writing vocabularies to database. Go grab a coffee...")

    if (database_engine == "sqlite") {
      ## Ok wow this is taking a LONG time.
      my_vocab <- prep_sqlite_vocabularies(my_vocab)
      my_vocab <- fix_vocabulary_constraints(my_vocab)
    }

    iwalk(my_vocab, ~ write_notify(conn = ctn, name = .y, value = .x))
    inform("Vocabularies copied to database")
    speak_utter_nonsense()
    rm(my_vocab)

  }

  transact(ctn, "COMMIT;")
  transact(ctn, "VACUUM;")

  # inform("Copying clinical tables to database")
  #
  # # ACTIVATE INDEXES ====
  # inform("Adding Indexes")
  # if (indexes) {
  #   create_indexes(ctn, cdm_version, database_engine, project_path)
  # }
  #
  # inform("Adding Constraints")
  # # ACTIVATE CONSTRAINTS ====
  # if (constraints) {
  #   activate_constraints(ctn, cdm_version, database_engine, project_path)
  # }

  fend <- Sys.time()
  dur <- round(as.numeric((fend - fstart))/60, 2)
  inform("Finished CDM build")
  inform(glue("Congratulations, your OMOP setup completed in {dur} hours"))

  dbDisconnect(ctn)
  return(TRUE)
}

