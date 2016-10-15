#' @export
runExample <- function(example) {
    examplesDir <- "examples"
    appDir <- system.file(examplesDir, example, package = .packageName)
  
    if (appDir == "") {
        examples <- list.files(system.file(examplesDir, package = .packageName))
        stop(sprintf("Example '%s' not found.\nValid examples:\n%s", example, paste(examples, collapse ="\n")))
    }

    shiny::runApp(appDir)
}
