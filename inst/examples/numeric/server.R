library(interviewer)
library(shiny)

function(input, output, session) {

    output$questionnaireOutput <-
        interviewer::questionnaire(
            surveyId = "interviewer-demo-numeric",
            userId = "demo",
            label = "Numeric DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>numeric</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",

            interviewer::page(
                id = "Numeric",

                interviewer::question.numeric(
                    id = "NumericStandard",
                    label = "Numeric, standard",
                    min = 0,
                    max = 20
                ),

                interviewer::question.numeric(
                    id = "NumericOptional",
                    label = "Numeric, no response required (required set to FALSE)",
                    min = 0,
                    max = 20,
                    required = FALSE
                ),

                interviewer::question.numeric(
                    id = "NumericStep",
                    label = "Numeric, step set to 5",
                    min = 0,
                    max = 20,
                    step = 5
                ),

                interviewer::buildQuestion(
                    id = "NumericStepNote",
                    ui = shiny::p("Note: in the above, the step is set to help the user enter values, it is not used to validate data.")
                ),

                interviewer::question.numeric(
                    id = "NumericNarrow",
                    label = "Numeric, narrow (width set to '200px')",
                    min = 0,
                    max = 20,
                    width = "200px"
                )
            ),

            interviewer::page(
                id = "Slider",

                interviewer::question.numeric(
                    id = "SliderStandard",
                    label = "Slider, standard",
                    min = 0,
                    max = 20,
                    use.slider = TRUE
                ),

                interviewer::question.numeric(
                    id = "SliderStep",
                    label = "Slider, step set to 5",
                    min = 0,
                    max = 20,
                    step = 5,
                    use.slider = TRUE
                ),

                interviewer::question.numeric(
                    id = "SliderNarrow",
                    label = "Slider, narrow (width set to '200px'):",
                    min = 0,
                    max = 20,
                    width = "200px",
                    use.slider = TRUE
                )
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
