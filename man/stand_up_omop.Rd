% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stand_up_omop.R
\name{stand_up_omop}
\alias{stand_up_omop}
\title{Create an empty OMOP database}
\usage{
stand_up_omop(
  project_path,
  cdm_version = c("5.3.1", "6.0.0"),
  vocabulary_version = "5",
  database_name = NULL,
  database_schema = "public",
  database_engine = c("sqlite", "postgres"),
  host_name = "localhost",
  port_no = 5432,
  username = NULL,
  vocabulary = TRUE,
  indexes = TRUE,
  constraints = TRUE
)
}
\arguments{
\item{project_path}{the path to your project folder with the following
populated folders: \itemize{\item \code{vocab}: contains ATHENA vocabularies. }}

\item{cdm_version}{the version of the CDM you are using, choose from:
\itemize{ \item "5.3.1" \item "6.0.0" }}

\item{vocabulary_version}{the version of the vocabulary you are using}

\item{database_name}{the name of the database you are connecting to. In the
case of using SQLite, this is the file path to the database.}

\item{database_schema}{the schema name of the target database. Defaults to "public".}

\item{database_engine}{the database engine, choose from:
\itemize{
\item sqlite
\item postgres
}}

\item{host_name}{host ip address}

\item{port_no}{port number}

\item{username}{username to database (\emph{must} have write privileges)}

\item{vocabulary}{logical: do you want to write out vocabularies?}

\item{indexes}{logical: do you want to apply indexes?}

\item{constraints}{logical: do you want to apply relational constraints?}
}
\value{
\code{TRUE} if completed without errors and writing to database
}
\description{
At the moment, this just creates the Athena vocabularies. Can
easily add functionality to write out the clinical tables if necessary.
This function instantiates an OHDSI CDM (referred to throughout as OMOP for
brevity) database from the standardised vocabularies. It can be specified
to output either version 5.3.1 or 6.0.0. After the OMOP database has been
created, you have the option to add clinical data directly.
}
