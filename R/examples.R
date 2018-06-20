#' Run one of the \code{interviewer} examples.
#'
#' \code{runExample} runs one of the examples distributed wiht the \code{interviewer} package.
#'
#' @param example (character) the directory name of one of the sub-directories in the pacakge's
#'     \code{inst/examples/} directory. Call \code{runExample()} with no arguments to get a list
#'     of valid examples.
#' @param ... other parameters to pass to Shiny's \code{runApp()} function,
#'     e.g. set \code{display.mode} to \code{"showcase"} to see the example's code.
#'
#' @seealso
#'     \code{\link[shiny]{runApp}}.
#' @export
runExample <- function(example, ...) {
    examplesDir <- "examples"
    examples <- list.files(system.file(examplesDir, package = .packageName))
    exampleList <- sprintf("\n\nValid examples:\n  %s", paste0("\"", examples, "\"", collapse ="\n  "))

    if (missing(example)) {
        stop(sprintf("Example name missing.%s", exampleList))
    }

    appDir <- system.file(examplesDir, example, package = .packageName)

    if (appDir == "") {
        stop(sprintf("Example '%s' not found.%s", example, exampleList))
    }

    shiny::runApp(appDir, ...)
}
