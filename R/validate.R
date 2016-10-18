
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
        questionId <- .questionId(question$id)
        
        if (!.isAnswered(input[[questionId]])) {
            result <- "Response required."
        }
    }
    
    result
}

.validateResult <- function(question) {
    result <- .validResult
    
    if (!is.null(question$validate)) {
        result <- question$validate()
    } else {
        result <- .validateIsAnswered(question)
    }
    
    result
}
