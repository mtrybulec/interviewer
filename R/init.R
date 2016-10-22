#' Set up \code{interviewer} in a Shiny app.
#'
#' \code{useInterviewer} should be called from a Shiny app's UI
#'     in order for some of the other \code{interviewer} functions to work correctly.
#'     It can be called from anywhere inside the UI.
#'     It also calls \code{useShinyjs()} to set up \code{shinyjs}.
#'
#' @seealso
#'     \code{\link{runExample}},
#'     \code{\link[shinyjs]{useShinyjs}}.
#' @export
useInterviewer <- function() {
    shiny::addResourcePath(.packageName, system.file("www", package = .packageName))

    jsFile <- file.path(.packageName, "main.js")
    cssFile <- file.path(.packageName, "main.css")

    list(
        shinyjs::useShinyjs(),
        shiny::singleton(
            shiny::tags$head(
                shiny::tags$script(src = jsFile),
                shiny::tags$link(href = cssFile, rel = "stylesheet")
            )
        )
    )
}
