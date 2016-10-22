library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            surveyId = "interviewer-demo-single-choice",
            userId = "demo",
            label = "Single-choice DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>single-choice</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",

            interviewer::question.list(
                id = "FilterSource",
                label = "Filter source (responses A and B filter one of the next questions)",
                responses = responses
            ),

            interviewer::pageBreak(),

            function(context) {
                if (getResponseIds("FilterSource") == "a") {
                    interviewer::question.list(
                        id = "FilterTargetA",
                        label = "Filter target A (asked if the response to the first question was 'response A')",
                        responses = responses
                    )
                } else if (getResponseIds("FilterSource") == "b") {
                    list(
                        interviewer::question.list(
                            id = "FilterTargetB",
                            label = "Filter target B (asked if the response to the first question was 'response B')",
                            responses = responses
                        ),

                        interviewer::pageBreak(),

                        function(context) {
                            if (getResponseIds("FilterTargetB") == "c") {
                                interviewer::question.list(
                                    id = "FilterTargetBC",
                                    label = "Filter target B -> C (asked if the response to the first question was 'response B' and 'response C')",
                                    responses = responses
                                )
                            }
                        }
                    )
                }
            },

            interviewer::question.list(
                id = "NonFilter",
                label = "Not filtered (asked regardless of the response to the first question)",
                responses = responses
            ),

            interviewer::pageBreak(),

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
