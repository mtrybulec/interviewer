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
                if (is.list(question) && all(c("id", "ui") %in% names(question))) {
                    result <- list(
                        id = .questionId(question$id),
                        required = question$required
                    )
                } else {
                    result <- NULL
                }
                
                result    
            }),
        ui = function(context) {
            shiny::tags$div(
                id = id,
                class = "page",
                lapply(questions, function(question) {
                    if (is.list(question) && all(c("id", "ui") %in% names(question))) {
                        if ("dataIds" %in% names(question)) {
                            dataIds <- setdiff(question$dataIds, context$questionOrder)
                            context$questionOrder <- c(context$questionOrder, dataIds)
                        } else if (!(question$id %in% context$questionOrder)) {
                            context$questionOrder <- c(context$questionOrder, question$id)
                        }

                        questionId <- .questionId(question$id)
                        questionStatusId <- .questionStatusId(questionId)
                        
                        result <- list(
                            question$ui(context), 
                            shiny::uiOutput(outputId = questionStatusId)
                        )
                        
                        output[[questionStatusId]] <- shiny::renderUI({
                            if (context$pageIndex %in% context$visitedPageIndexes) {
                                if (!.isAnswered(input[[questionId]])) {
                                    if ((!is.null(question$required)) && question$required) {
                                        shiny::HTML(paste("<div class=\"interviewer-question-status\">", "Response required.", "</div>", sep = ""))
                                    }
                                }
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
