
.emptyResponseValue <- ""

.isAnswered <- function(item) {
    (!is.null(item)) && (!is.na(item)) && (item != .emptyResponseValue)
}

.validResult <- ""

.validateIsAnswered <- function(question) {
    result <- .validResult
    
    if ((!is.null(question$required)) && question$required) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input
        questionInputId <- makeQuestionInputId(question$id)
        
        if (!.isAnswered(input[[questionInputId]])) {
            result <- "Response required."
        }
    }
    
    result
}

.validateResult <- function(context, question) {
    result <- .validResult
    
    if (!is.null(question$validate)) {
        result <- question$validate(context)
    } else {
        result <- .validateIsAnswered(question)
    }
    
    result
}
