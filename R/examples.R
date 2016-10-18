#' Run one of the \code{interviewer} examples.
#' 
#' \code{runExample} runs one of the examples distributed wiht the \code{interviewer} package.
#' 
#' @param example (character) the directory name of one of the sub-directories in the pacakge's
#'     \code{inst/examples/} directory. Call \code{runExample()} with no parameters to get a list
#'     of valid examples.
#'     
#' @export
runExample <- function(example) {
    examplesDir <- "examples"
    examples <- list.files(system.file(examplesDir, package = .packageName))
    exampleList <- sprintf("\n\nValid examples:\n  %s", paste(examples, collapse ="\n  "))
    
    if (missing(example)) {
        stop(sprintf("Example name missing.%s", exampleList))
    }
    
    appDir <- system.file(examplesDir, example, package = .packageName)
  
    if (appDir == "") {
        stop(sprintf("Example '%s' not found.%s", example, exampleList))
    }

    shiny::runApp(appDir)
}
