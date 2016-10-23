library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            surveyId = "interviewer-demo-loop",
            userId = "demo",
            label = "Loop DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>loops</strong> can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",

            interviewer::question.list(
                id = "LoopSource",
                label = "Loop source (two questions will be asked for each response mentioned here, in random order)",
                responses = responses,
                multiple = TRUE
            ),

            interviewer::pageBreak(),

            function() {
                result <- list()
                responseIds <- getResponseIds("LoopSource")
                # Randomize subsequent blocks:
                responseIds <- responseIds[sample(length(responseIds))]

                result <- lapply(responseIds, function(responseId) {
                    responseLabel <- responses[which(responses$id == responseId), "label"]

                    list(
                        interviewer::question.list(
                            id = paste0("LoopQuestion1", responseId),
                            label = sprintf("Loop question 1 for '%s'", responseLabel),
                            responses = responses
                        ),

                        interviewer::question.list(
                            id = paste0("LoopQuestion2", responseId),
                            label = sprintf("Loop question 2 for '%s'", responseLabel),
                            responses = responses
                        ),

                        interviewer::pageBreak()
                    )
                })

                unlist(result, recursive = FALSE)
            },

            interviewer::question.list(
                id = "Final",
                label = "Final",
                responses = responses
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
