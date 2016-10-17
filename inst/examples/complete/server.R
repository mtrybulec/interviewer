library(interviewer)
library(shiny)
library(shinyjs)

function(input, output, session) {

    output$questionnaireOutput <- 
        questionnaire(
            surveyId = "interviewer-demo-complete",
            userId = "demo",
            label = "Interviewer DEMO",
            welcome = list(
                p("Welcome!"),
                HTML("<p>This demo shows a relatively complete set of <strong>interviewer</strong> questions and options.</p>")
            ),
            goodbye = "Done!",
            
            page(id = "1",
                question.list(
                    id = "Sex",
                    label = "Please enter your sex:",
                    responses = data.frame(
                        ids = c("m", "f"),
                        labels = c("male", "female")
                    )
                ),

                question.list(
                    id = "Age",
                    label = "Please enter your age:",
                    responses = data.frame(
                        ids = c("<=20", "21-30", "31-40", ">40"),
                        labels = c("20 or younger", "21 to 30", "31 to 40", "older than 40")
                    ),
                    displayList = TRUE
                )
            ),
            
            page(id = "2",
                question.list(
                    id = "MaritalStatus",
                    label = "What is your marital status?",
                    responses = data.frame(
                        ids = c("s", "m", "o"),
                        labels = c("single", "married", "other")
                    ),
                    required = FALSE
                ),
                
                question.list(
                    id = "Owns",
                    label = "Select, from the list, all items that you own:",
                    responses = data.frame(
                        ids = c("sph", "t", "lt", "dt"),
                        labels = c("smartphone", "tablet", "laptop", "desktop")
                    ),
                    displayList = TRUE,
                    multiple = TRUE,
                    required = FALSE
                )
            ),

            page(id = "3",
                 question.list(
                    id = "Pets",
                    label = "What pets do you have?",
                    multiple = TRUE,
                    responses = data.frame(
                        ids = c("c", "d", "s"),
                        labels = c("cat", "dog", "spider")
                    )
                ),

                question.numeric(
                    id = "Cars",
                    label = "How many cars do you have?",
                    min = 0,
                    max = 10,
                    use.slider = TRUE
                ),

                question.numeric(
                    id = "Kids",
                    label = "How many kids do you have?",
                    min = 0,
                    max = 20
                )
            ),

            # Page with a custom question:
            page(id = "C",
                 list(
                     id = "chart",
                     dataIds = paste0("Price", c(1:12)),
                     ui = function(context) {
                         priceInput <- function(month) {
                             questionId <- paste0("questionPrice", month)
                             numericInput(inputId = questionId, 
                                          label = month.abb[month], 
                                          min = 1, 
                                          max = 1000, 
                                          value = isolate(input[[questionId]]))
                         }
                         
                         fluidRow(
                             column(4, lapply(1:6, function(month) priceInput(month))),
                             column(4, lapply(7:12, function(month) priceInput(month))),
                             column(4, plotOutput(outputId = "questionPricePlot"))
                         )
                     } 
                 )
            ),
            
            page(id = "4",
                 question.text(
                     id = "Nick",
                     label = "What's your nickname?"
                 ),

                 HTML("<p>Now, before you answer the next question,<br />please take a moment to think...</p>"),

                 question.text(
                     id = "Comment",
                     label = "Anything you want to add?",
                     cols = 80,
                     rows = 3
                 ),
                 
                 p("The question below has responses ordered randomly (except for the last response)."),
                 
                 question.list(
                     id = "Random",
                     label = "Which continents have you ever been to?",
                     responses = {
                         responses <- data.frame(
                             ids = c("af", "as", "an", "au", "eu", "na", "sa"),
                             labels = c("Africa", "Asia", "Antarctica", "Australia", "Europe", "North America", "South America")
                         )
                         
                         rand <- sample(nrow(responses))
                         
                         rbind(responses[rand, ], data.frame(ids = "dk", labels = "Don't know..."))
                     },
                     multiple = TRUE
                 )
            ),
            
            page(id = "5",
                 question.list(
                     id = "Like",
                     label = "Did you like the questionnaire?",
                     responses = data.frame(
                         ids = c("y", "n"),
                         labels = c("Yes", "No")
                     )
                 )
            ),
            
            onExit = function(data) {
                cat("onExit:\n")
                print(data)
            }
        )

    output$questionPricePlot <- renderPlot({
        ifNotNA <- function(currentValue, nonNullValue) {
            if (is.na(currentValue)) {
                nonNullValue
            } else {
                currentValue
            }
        }
        
        prices <- data.frame(value = integer(0))

        for (month in 1:12) {
            prices[month, "value"] <- ifNotNA(input[[paste0("questionPrice", month)]], 0)    
        }

        plot(prices$value, type = "l")
    })

}
