library(interviewer)
library(shiny)

function(input, output, session) {

    output$questionnaireOutput <- 
        interviewer::questionnaire(
            surveyId = "interviewer-demo-complete",
            userId = "demo",
            label = "Interviewer DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows a relatively complete set of <strong>interviewer</strong> questions and options.</p>")
            ),
            goodbye = "Done!",
            
            interviewer::page(id = "1",
                interviewer::question.list(
                    id = "Sex",
                    label = "Please enter your sex:",
                    responses = data.frame(
                        ids = c("m", "f"),
                        labels = c("male", "female")
                    )
                ),

                interviewer::question.list(
                    id = "Age",
                    label = "Please enter your age:",
                    responses = data.frame(
                        ids = c("<=20", "21-30", "31-40", ">40"),
                        labels = c("20 or younger", "21 to 30", "31 to 40", "older than 40")
                    ),
                    use.select = TRUE
                )
            ),
            
            interviewer::page(id = "2",
                interviewer::question.list(
                    id = "MaritalStatus",
                    label = "What is your marital status?",
                    responses = data.frame(
                        ids = c("s", "m", "o"),
                        labels = c("single", "married", "other")
                    ),
                    required = FALSE
                ),
                
                interviewer::question.list(
                    id = "Owns",
                    label = "Select, from the list, all items that you own:",
                    responses = data.frame(
                        ids = c("sph", "t", "lt", "dt"),
                        labels = c("smartphone", "tablet", "laptop", "desktop")
                    ),
                    use.select = TRUE,
                    multiple = TRUE,
                    required = FALSE
                )
            ),

            interviewer::page(id = "3",
                interviewer::question.list(
                    id = "Pets",
                    label = "What pets do you have?",
                    multiple = TRUE,
                    responses = data.frame(
                        ids = c("c", "d", "s"),
                        labels = c("cat", "dog", "spider")
                    )
                ),

                interviewer::question.numeric(
                    id = "Cars",
                    label = "How many cars do you have?",
                    min = 0,
                    max = 10,
                    use.slider = TRUE
                ),

                interviewer::question.numeric(
                    id = "Kids",
                    label = "How many kids do you have?",
                    min = 0,
                    max = 20
                )
            ),

            # Page with a custom question:
            interviewer::page(id = "C",
                list(
                    id = "chart",
                    dataIds = paste0("Price", c(1:12)),
                    ui = function(context) {
                        priceInput <- function(month) {
                            questionId <- paste0("questionPrice", month)
                            shiny::numericInput(inputId = questionId, 
                                                label = month.abb[month], 
                                                min = 1, 
                                                max = 1000, 
                                                value = shiny::isolate(input[[questionId]]))
                        }
                         
                        shiny::fluidRow(
                            shiny::column(4, lapply(1:6, function(month) priceInput(month))),
                            shiny::column(4, lapply(7:12, function(month) priceInput(month))),
                            shiny::column(4, shiny::plotOutput(outputId = "questionPricePlot"))
                        )
                    } 
                )
            ),
            
            interviewer::page(id = "4",
                interviewer::question.text(
                    id = "Nick",
                    label = "What's your nickname?"
                ),

                interviewer::question.text(
                    id = "Phone",
                    label = "What is your phone number? [xxx xxx-xxx]",
                    regex = "\\d{3} \\d{3}-\\d{3}"
                ),
                
                shiny::HTML("<p>Now, before you answer the next question,<br />please take a moment to think...</p>"),

                interviewer::question.text(
                    id = "Comment",
                    label = "Anything you want to add?",
                    cols = 80,
                    rows = 3,
                    use.textArea = TRUE
                ),
                 
                shiny::p("The question below has responses ordered randomly (except for the last response)."),
                 
                interviewer::question.list(
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
            
            interviewer::page(id = "5",
                interviewer::question.list(
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

    output$questionPricePlot <- shiny::renderPlot({
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
