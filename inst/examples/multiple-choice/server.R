library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Multiple-choice DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>multiple-choice</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),

            interviewer::question.multiple(
                id = "CheckBoxesStandard",
                label = "Check-boxes, standard",
                responses = responses
            ),

            interviewer::question.multiple(
                id = "CheckBoxesInline",
                label = "Check-boxes, inline (inline set to TRUE)",
                responses = responses,
                inline = TRUE
            ),

            interviewer::question.multiple(
                id = "CheckBoxesOptional",
                label = "Check-boxes, no response required (required set to FALSE)",
                responses = responses,
                required = FALSE
            ),

            interviewer::question.multiple(
                id = "CheckBoxesNarrow",
                label = "Check-boxes, inline and narrow (width set to '250px')",
                responses = responses,
                inline = TRUE,
                width = "250px"
            ),

            interviewer::pageBreak(),

            interviewer::question.multiple(
                id = "ComboBoxStandard",
                label = "Combo-box, standard (use.select set to TRUE)",
                responses = responses,
                use.select = TRUE
            ),

            interviewer::question.multiple(
                id = "ComboBoxPlaceholder",
                label = "Combo-box, custom message (placeholder set to 'I need a response!')",
                responses = responses,
                use.select = TRUE,
                placeholder = "I need a response!"
            ),

            interviewer::question.multiple(
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

            interviewer::question.multiple(
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
