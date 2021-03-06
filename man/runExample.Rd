% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/examples.R
\name{runExample}
\alias{runExample}
\title{Run one of the \code{interviewer} examples.}
\usage{
runExample(example, ...)
}
\arguments{
\item{example}{(character) the directory name of one of the sub-directories in the pacakge's
\code{inst/examples/} directory. Call \code{runExample()} with no arguments to get a list
of valid examples.}

\item{...}{other parameters to pass to Shiny's \code{runApp()} function,
e.g. set \code{display.mode} to \code{"showcase"} to see the example's code.}
}
\description{
\code{runExample} runs one of the examples distributed wiht the \code{interviewer} package.
}
\seealso{
\code{\link[shiny]{runApp}}.
}
