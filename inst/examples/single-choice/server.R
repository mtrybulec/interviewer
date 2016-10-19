library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- buildResponses(
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

            interviewer::page(id = "radioButtons",
                interviewer::question.list(
                    id = "RadioButtonsStandard",
                    label = "Radio-buttons, standard",
                    responses = responses
                ),

                interviewer::question.list(
                    id = "RadioButtonsInline",
                    label = "Radio-buttons, inline (inline set to TRUE)",
                    responses = responses,
                    inline = TRUE
                ),

                interviewer::question.list(
                    id = "RadioButtonsOptional",
                    label = "Radio-buttons, no response required (required set to FALSE; a second click on a selected radio-button deselects it)",
                    responses = responses,
                    required = FALSE
                ),

                interviewer::question.list(
                    id = "RadioButtonsNarrow",
                    label = "Radio-buttons, inline and narrow (width set to '200px')",
                    responses = responses,
                    inline = TRUE,
                    width = "200px"
                )
            ),

            interviewer::page(id = "comboBoxes",
                interviewer::question.list(
                    id = "ComboBoxStandard",
                    label = "Combo-box, standard (use.select set to TRUE)",
                    responses = responses,
                    use.select = TRUE
                ),

                interviewer::question.list(
                    id = "ComboBoxPlaceholder",
                    label = "Combo-box, custom message (selectizePlaceholder set to 'I need a response!')",
                    responses = responses,
                    use.select = TRUE,
                    selectizePlaceholder = "I need a response!"
                ),

                interviewer::question.list(
                    id = "ComboBoxOptional",
                    label = "Combo-box, no response required (required set to FALSE)",
                    responses = responses,
                    use.select = TRUE,
                    selectizePlaceholder = "This question is optional",
                    required = FALSE
                ),

                shiny::p(paste(
                    "Note how the combo-box below is displayed on top of the survey buttons. ",
                    "Take care when designing such screens (works ok for single-choice questions, but may not for multi-choice ones)."
                )),

                interviewer::question.list(
                    id = "ComboBoxNarrow",
                    label = "Combo-box, narrow (width set to '200px')",
                    responses = responses,
                    use.select = TRUE,
                    width = "200px"
                )
            ),

            onExit = function(data) {
                cat("onExit:\n")
                print(data)
            }
        )

}
