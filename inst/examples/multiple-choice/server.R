library(interviewer)
library(shiny)

function(input, output, session) {
    
    responses <- data.frame(
        ids = c("a", "b", "c"),
        labels = c("response A", "response B", "response C")
    )
    
    output$questionnaireOutput <- 
        questionnaire(
            surveyId = "interviewer-demo-multiple-choice",
            userId = "demo",
            label = "Multiple-choice DEMO",
            welcome = list(
                p("Welcome!"),
                HTML("<p>This demo shows how <strong>multiple-choice</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",
            
            page(id = "checkBoxes",
                question.list(
                    id = "CheckBoxesStandard",
                    label = "Check-boxes, standard (multiple parameter set to TRUE)",
                    responses = responses,
                    multiple = TRUE
                ),

                question.list(
                    id = "CheckBoxesInline",
                    label = "Check-boxes, inline (inline parameter set to TRUE)",
                    responses = responses,
                    multiple = TRUE,
                    inline = TRUE
                ),
                
                question.list(
                    id = "CheckBoxesOptional",
                    label = "Check-boxes, no response required (required parameter set to FALSE)",
                    responses = responses,
                    multiple = TRUE,
                    required = FALSE
                ),
                
                question.list(
                    id = "CheckBoxesNarrow",
                    label = "Check-boxes, inline and narrow (width parameter set to '200px')",
                    responses = responses,
                    multiple = TRUE,
                    inline = TRUE,
                    width = "200px"
                )
            ),
            
            page(id = "comboBoxes",
                 question.list(
                     id = "ComboBoxStandard",
                     label = "Combo-box, standard (use.select parameter set to TRUE)",
                     responses = responses,
                     multiple = TRUE,
                     use.select = TRUE
                 ),
                 
                 question.list(
                     id = "ComboBoxPlaceholder",
                     label = "Combo-box, custom message (set via the selectizePlaceholder parameter)",
                     responses = responses,
                     use.select = TRUE,
                     multiple = TRUE,
                     selectizePlaceholder = "I need a response!"
                 ),
                 
                 question.list(
                     id = "ComboBoxOptional",
                     label = "Combo-box, no response required (required parameter set to FALSE)",
                     responses = responses,
                     use.select = TRUE,
                     multiple = TRUE,
                     selectizePlaceholder = "This question is optional",
                     required = FALSE
                 ),
                 
                 p(paste(
                     "Note how the combo-box below is displayed on top of the survey buttons. ",
                     "Take care when designing such screens (works ok for single-choice questions, but may not for multi-choice ones)."
                 )),
                                  
                 question.list(
                     id = "ComboBoxNarrow",
                     label = "Combo-box, narrow (width parameter set to '200px')",
                     responses = responses,
                     use.select = TRUE,
                     multiple = TRUE,
                     width = "200px"
                 )
            ),
            
            onExit = function(data) {
                cat("onExit:\n")
                print(data)
            }
        )

}
