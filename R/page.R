#' @export
page <- function(id, ...) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    output <- domain$output

    id <- .pageId(id)
    questions <- list(...)

    list(
        id = id,
        questions = 
            lapply(questions, function(question) {
                if (.isQuestion(question)) {
                    result <- question
                } else {
                    result <- NULL
                }
                
                result    
            }),
        ui = function(context) {
            shiny::div(
                id = id,
                class = "page",
                lapply(questions, function(question) {
                    if (.isQuestion(question)) {
                        if ("dataIds" %in% names(question)) {
                            dataIds <- setdiff(question$dataIds, context$questionOrder)
                            context$questionOrder <- c(context$questionOrder, dataIds)
                        } else if (!(question$id %in% context$questionOrder)) {
                            context$questionOrder <- c(context$questionOrder, question$id)
                        }

                        questionInputId <- makeQuestionInputId(question$id)
                        questionStatusId <- .questionStatusId(questionInputId)
                        
                        result <- list(
                            question$ui(context), 
                            shiny::uiOutput(outputId = questionStatusId)
                        )
                        
                        output[[questionStatusId]] <- shiny::renderUI({
                            validationResult <- context$validationResults[[question$id]]

                            if (!is.null(validationResult) && (validationResult != .validResult)) {
                                shiny::div(class = "interviewer-question-status", shiny::HTML(validationResult))
                            }
                        })
                    } else {
                        result <- question
                    }
                    
                    result    
                })
            )
        }
    )
}
