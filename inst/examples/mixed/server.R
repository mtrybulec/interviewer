library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c", "d", "e"),
        label = c("response A", "response B", "response C", "response D", "response E")
    )

    types <- c("checkbox", "checkbox", "checkbox", "radio", "radio")

    output$questionnaireOutput <-
        interviewer::questionnaire(
            surveyId = "interviewer-demo-mixed",
            userId = "demo",
            label = "Mixed DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>mixed</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",

            interviewer::page(id = "mixedButtons",
                interviewer::question.mixed(
                    id = "MixedStandard",
                    label = "Mixed standard",
                    responses = responses,
                    types = types
                ),

                interviewer::question.mixed(
                    id = "MixedInline",
                    label = "Mixed, inline (inline set to TRUE)",
                    responses = responses,
                    types = types,
                    inline = TRUE
                ),

                interviewer::question.mixed(
                    id = "MixedOptional",
                    label = "Mixed, no response required (required set to FALSE; a second click on a selected radio-button deselects it)",
                    responses = responses,
                    types = types,
                    required = FALSE
                ),

                interviewer::question.mixed(
                    id = "MixedNarrow",
                    label = "Mixed, inline and narrow (width set to '250px')",
                    responses = responses,
                    types = types,
                    inline = TRUE,
                    width = "250px"
                )
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
