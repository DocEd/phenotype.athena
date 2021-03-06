% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_vocabularies.R
\name{prep_sqlite_vocabularies}
\alias{prep_sqlite_vocabularies}
\title{Prepare Athena Vocabularies for loading into SQLite}
\usage{
prep_sqlite_vocabularies(vocab)
}
\arguments{
\item{vocab}{a list of vocabularies returned from \code{extract_vocab()}}
}
\value{

}
\description{
SQLite does not have native types for dates or times. Rather is can only
support text, floating points, integers and blobs. As a result, it is
referable to convert all dates and times into text before loading, to ensure
that the date representation is in a human readable format.
Functions to efficiently parse these data are part of the core SQLite code
base.
}
