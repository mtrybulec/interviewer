library(interviewer)
library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            surveyId = "interviewer-demo-multiple-choice",
            userId = "demo",
            label = "Multiple-choice DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>multiple-choice</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",

            interviewer::page(
                id = "CheckBoxes",

                interviewer::question.list(
                    id = "CheckBoxesStandard",
                    label = "Check-boxes, standard (multiple set to TRUE)",
                    responses = responses,
                    multiple = TRUE
                ),

                interviewer::question.list(
                    id = "CheckBoxesInline",
                    label = "Check-boxes, inline (inline set to TRUE)",
                    responses = responses,
                    multiple = TRUE,
                    inline = TRUE
                ),

                interviewer::question.list(
                    id = "CheckBoxesOptional",
                    label = "Check-boxes, no response required (required set to FALSE)",
                    responses = responses,
                    multiple = TRUE,
                    required = FALSE
                ),

                interviewer::question.list(
                    id = "CheckBoxesNarrow",
                    label = "Check-boxes, inline and narrow (width set to '250px')",
                    responses = responses,
                    multiple = TRUE,
                    inline = TRUE,
                    width = "250px"
                )
            ),

            interviewer::page(
                id = "ComboBoxes",

                interviewer::question.list(
                    id = "ComboBoxStandard",
                    label = "Combo-box, standard (use.select set to TRUE)",
                    responses = responses,
                    multiple = TRUE,
                    use.select = TRUE
                ),

                interviewer::question.list(
                    id = "ComboBoxPlaceholder",
                    label = "Combo-box, custom message (selectizePlaceholder set to 'I need a response!')",
                    responses = responses,
                    use.select = TRUE,
                    multiple = TRUE,
                    selectizePlaceholder = "I need a response!"
                ),

                question.list(
                    id = "ComboBoxOptional",
                    label = "Combo-box, no response required (required set to FALSE)",
                    responses = responses,
                    use.select = TRUE,
                    multiple = TRUE,
                    selectizePlaceholder = "This question is optional",
                    required = FALSE
                ),

                interviewer::buildQuestion(
                    id = "ComboBoxNarrowNote",
                    ui = shiny::p(paste(
                        "Note how the combo-box below is displayed on top of the survey buttons. ",
                        "Take care when designing such screens (works ok for single-choice questions, but may not for multi-choice ones)."
                    ))
                ),

                interviewer::question.list(
                    id = "ComboBoxNarrow",
                    label = "Combo-box, narrow (width set to '200px')",
                    responses = responses,
                    use.select = TRUE,
                    multiple = TRUE,
                    width = "200px"
                )
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
