library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c", "d", "e"),
        label = c("response A", "response B", "response C", "response D", "response E")
    )

    types <- c(
        rep(interviewer::mixedOptions.multiple, 3),
        rep(interviewer::mixedOptions.single, 2)
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Mixed-choice DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>mixed-choice</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),

            interviewer::question.mixed(
                id = "MixedButtonsStandard",
                label = "Mixed buttons, standard",
                responses = responses,
                types = types
            ),

            interviewer::question.mixed(
                id = "MixedButtonsInline",
                label = "Mixed buttons, inline (inline set to TRUE)",
                responses = responses,
                types = types,
                inline = TRUE
            ),

            interviewer::question.mixed(
                id = "MixedButtonsOptional",
                label = "Mixed buttons, no response required (required set to FALSE; a second click on a selected radio-button deselects it)",
                responses = responses,
                types = types,
                required = FALSE
            ),

            interviewer::question.mixed(
                id = "MixedButtonsNarrow",
                label = "Mixed buttons, inline and narrow (width set to '250px')",
                responses = responses,
                types = types,
                inline = TRUE,
                width = "250px"
            ),

            interviewer::pageBreak(),

            interviewer::buildNonQuestion(
                ui = shiny::p(paste(
                    "While you can use combo-boxes to handle mixed-choice questions,",
                    "that may not be too intuitive to the respondent (why do some responses remove other responses)."
                ))
            ),

            interviewer::question.mixed(
                id = "MixedComboBoxStandard",
                label = "Mixed combo-box, standard (use.select set to TRUE)",
                responses = responses,
                types = types,
                use.select = TRUE
            ),

            interviewer::question.mixed(
                id = "MixedComboBoxPlaceholder",
                label = "Mixed combo-box, custom message (placeholder set to 'I need a response!')",
                responses = responses,
                types = types,
                use.select = TRUE,
                placeholder = "I need a response!"
            ),

            interviewer::question.mixed(
                id = "MixedComboBoxOptional",
                label = "Mixed combo-box, no response required (required set to FALSE)",
                responses = responses,
                types = types,
                use.select = TRUE,
                required = FALSE
            ),

            interviewer::buildNonQuestion(
                ui = shiny::p(paste(
                    "Note how the combo-box below is displayed on top of the survey buttons.",
                    "Take care when designing such screens."
                ))
            ),

            interviewer::question.mixed(
                id = "MixedComboBoxNarrow",
                label = "Mixed combo-box, inline and narrow (width set to '200px')",
                responses = responses,
                types = types,
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
