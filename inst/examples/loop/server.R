library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Loop DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>loops</strong> can be defined in <strong>interviewer</strong>.</p>")
            ),

            interviewer::question.multiple(
                id = "LoopSource",
                label = "Loop source (two questions will be asked for each response mentioned here, in random order)",
                responses = responses
            ),

            interviewer::pageBreak(),

            function() {
                result <- list()
                responseIds <- getResponseIds("LoopSource")
                responseIds <- responseIds[sample(length(responseIds))] # randomize subsequent blocks

                for (responseId in responseIds) {
                    responseLabel <- responses[which(responses$id == responseId), "label"]

                    result <- append(
                        result,
                        list(
                            interviewer::question.single(
                                id = paste0("LoopQuestion1", responseId),
                                label = sprintf("Loop question 1 for '%s'", responseLabel),
                                responses = responses
                            ),

                            interviewer::question.single(
                                id = paste0("LoopQuestion2", responseId),
                                label = sprintf("Loop question 2 for '%s'", responseLabel),
                                responses = responses
                            ),

                            interviewer::pageBreak()
                        )
                    )
                }

                result
            },

            interviewer::question.single(
                id = "Final",
                label = "Final",
                responses = responses
            ),

            goodbye = "Done!",
            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
