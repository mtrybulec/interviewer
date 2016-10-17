library(interviewer)
library(shiny)

function(input, output, session) {
    
    output$questionnaireOutput <- 
        questionnaire(
            surveyId = "interviewer-demo-numeric",
            userId = "demo",
            label = "Numeric DEMO",
            welcome = list(
                p("Welcome!"),
                HTML("<p>This demo shows how <strong>numeric</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",
            
            page(id = "numeric",
                question.numeric(
                    id = "NumericStandard",
                    label = "Numeric, standard",
                    min = 0,
                    max = 20
                ),

                question.numeric(
                    id = "NumericOptional",
                    label = "Numeric, no response required (required parameter set to FALSE)",
                    min = 0,
                    max = 20,
                    required = FALSE
                ),
                
                question.numeric(
                    id = "NumericStep",
                    label = "Numeric, step set to 5",
                    min = 0,
                    max = 20,
                    step = 5
                ),
                
                p("Note: in the above, the step is set to help the user enter values, it is not used to validate data."),
                
                question.numeric(
                    id = "NumericNarrow",
                    label = "Numeric, narrow (width parameter set to '200px')",
                    min = 0,
                    max = 20,
                    width = "200px"
                )
            ),
            
            page(id = "slider",
                 question.numeric(
                     id = "SliderStandard",
                     label = "Slider, standard",
                     min = 0,
                     max = 20,
                     use.slider = TRUE
                 ),
                 
                 question.numeric(
                     id = "SliderStep",
                     label = "Slider, step set to 5",
                     min = 0,
                     max = 20,
                     step = 5,
                     use.slider = TRUE
                 ),
                 
                 question.numeric(
                     id = "SliderNarrow",
                     label = "Slider, narrow (width parameter set to '200px'):",
                     min = 0,
                     max = 20,
                     width = "200px",
                     use.slider = TRUE
                 )
            ),
            
            onExit = function(data) {
                cat("onExit:\n")
                print(data)
            }
        )

}
