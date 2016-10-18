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
