library(interviewer)
library(shiny)
library(shinyjs)

function(input, output, session) {
    
    responses <- data.frame(
        ids = c("a", "b", "c"),
        labels = c("response A", "response B", "response C")
    )
    
    output$questionnaireOutput <- 
        questionnaire(
            surveyId = "interviewer-demo-single-choice",
            userId = "demo",
            label = "Single-choice DEMO",
            welcome = list(
                p("Welcome!"),
                p("This demo shows how single-choice questions can be defined in interviewer.")
            ),
            goodbye = "Done!",
            
            page(id = "radioButtons",
                question.list(
                    id = "RadioButtonsStandard",
                    label = "Radio-buttons, standard",
                    responses = responses
                ),

                question.list(
                    id = "RadioButtonsInline",
                    label = "Radio-buttons, inline (inline parameter set to TRUE):",
                    responses = responses,
                    inline = TRUE
                ),
                
                question.list(
                    id = "RadioButtonsOptional",
                    label = "Radio-buttons, no response required (a second click on a selected radio-button deselects it)",
                    responses = responses,
                    required = FALSE
                ),
                
                question.list(
                    id = "RadioButtonsNarrow",
                    label = "Radio-buttons, inline and narrow (width parameter set to '200px'):",
                    responses = responses,
                    inline = TRUE,
                    width = "200px"
                )
            ),
            
            page(id = "comboBoxes",
                 question.list(
                     id = "ComboBoxStandard",
                     label = "Combo-box, standard (displayList parameter set to TRUE)",
                     responses = responses,
                     displayList = TRUE
                 ),
                 
                 p(paste(
                     "Note how the combo-box below is displayed on top of the survey buttons. ",
                     "Take care when designing such screens (works ok for single-choice questions, but may not for multi-choice ones)."
                 )),
                                  
                 question.list(
                     id = "ComboBoxNarrow",
                     label = "Combo-box, inline and narrow (width parameter set to '200px'):",
                     responses = responses,
                     displayList = TRUE,
                     width = "200px"
                 )
            ),
            
            onExit = function(data) {
                cat("onExit:\n")
                print(data)
            }
        )

}
