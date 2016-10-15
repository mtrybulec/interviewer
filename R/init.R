#' @export
useInterviewer <- function() {
    shiny::addResourcePath(.packageName, system.file("www", package = .packageName))
    
    jsFile <- file.path(.packageName, "main.js")
    cssFile <- file.path(.packageName, "main.css")

    list(
        useShinyjs(),
        shiny::singleton(
            shiny::tags$head(
                shiny::tags$script(src = jsFile),
                shiny::tags$link(href = cssFile, rel = "stylesheet")
            )
        )    
    )    
}