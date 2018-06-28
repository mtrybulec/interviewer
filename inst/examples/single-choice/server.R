library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Single-choice DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>single-choice</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),

            interviewer::question.single(
                id = "RadioButtonsStandard",
                label = "Radio-buttons, standard",
                responses = responses
            ),

            interviewer::question.single(
                id = "RadioButtonsInline",
                label = "Radio-buttons, inline (inline set to TRUE)",
                responses = responses,
                inline = TRUE
            ),

            interviewer::question.single(
                id = "RadioButtonsOptional",
                label = "Radio-buttons, no response required (required set to FALSE; a second click on a selected radio-button deselects it)",
                responses = responses,
                required = FALSE
            ),

            interviewer::question.single(
                id = "RadioButtonsNarrow",
                label = "Radio-buttons, inline and narrow (width set to '250px')",
                responses = responses,
                inline = TRUE,
                width = "250px"
            ),

            interviewer::pageBreak(),

            interviewer::question.single(
                id = "ComboBoxStandard",
                label = "Combo-box, standard (use.select set to TRUE)",
                responses = responses,
                use.select = TRUE
            ),

            interviewer::question.single(
                id = "ComboBoxPlaceholder",
                label = "Combo-box, custom message (placeholder set to 'I need a response!')",
                responses = responses,
                use.select = TRUE,
                placeholder = "I need a response!"
            ),

            interviewer::question.single(
                id = "ComboBoxOptional",
                label = "Combo-box, no response required (required set to FALSE)",
                responses = responses,
                use.select = TRUE,
                placeholder = "This question is optional",
                required = FALSE
            ),

            interviewer::buildNonQuestion(
                ui = shiny::p(paste(
                    "Note how the combo-box below is displayed on top of the survey buttons.",
                    "Take care when designing such screens."
                ))
            ),

            interviewer::question.single(
                id = "ComboBoxNarrow",
                label = "Combo-box, narrow (width set to '200px')",
                responses = responses,
                use.select = TRUE,
                width = "200px"
            ),

            goodbye = "Done!",
            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
