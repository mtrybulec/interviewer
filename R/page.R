.pageBreak = "pageBreak"
.nonQuestion = "nonQuestion"

#' Define a page break.
#'
#' \code{pageBreak} splits the questionnaire into separate pages/screens.
#'
#' @export
pageBreak <- function() {
    list(type = .pageBreak)
}

#' Build a non-question (UI) element to show next to questions.
#'
#' \code{buildQuestion} returns a question definition given the parts
#'     a fully formed question definition consists of.
#'
#' @param ui (list|function) a list of UI components to show on screen
#'     or a function that should return the UI components to show on screen.
#'     Use a list to build static content and a function to build dynamic content.
#'
#' @seealso
#'     \code{\link{buildQuestion}}.
#' @export
buildNonQuestion <- function(ui) {
    list(
        type = .nonQuestion,
        ui = ui
    )
}
