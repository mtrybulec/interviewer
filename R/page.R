#' @export
page <- function(id, ...) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    output <- domain$output

    id <- .pageId(id)
    questions <- list(...)

    list(
        id = id,
        questions = questions,
        ui = function(context) {
            shiny::div(
                id = id,
                class = "page",
                lapply(questions, function(question) {
                    questionInputId <- makeQuestionInputId(question$id)
                    questionStatusId <- .questionStatusId(questionInputId)

                    output[[questionStatusId]] <- shiny::renderUI({
                        validationResult <- context$validationResults[[question$id]]

                        if (!is.null(validationResult) && (validationResult != .validResult)) {
                            shiny::div(class = "interviewer-question-status", shiny::HTML(validationResult))
                        }
                    })

                    if ((length(class(question$ui)) == 1) && (class(question$ui) == "function")) {
                        questionUI <- question$ui(context)
                    } else {
                        questionUI <- question$ui
                    }

                    list(
                        questionUI,
                        shiny::uiOutput(outputId = questionStatusId)
                    )
                })
            )
        }
    )
}
