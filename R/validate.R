
.emptyResponseValue <- ""

.isAnswered <- function(input) {
    (!is.null(input)) && (!is.na(input)) && (input != .emptyResponseValue)
}

.validResult <- ""

.validateIsAnswered <- function(question, required) {
    result <- .validResult

    if (required) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input
        questionInputId <- makeQuestionInputId(question$id)

        if (!.isAnswered(input[[questionInputId]])) {
            result <- "Response required."
        }
    }

    result
}

.validateResult <- function(question) {
    result <- .validResult

    if (!is.null(question$validate)) {
        result <- question$validate()
    }

    result
}
