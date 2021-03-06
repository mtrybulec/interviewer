library(interviewer)
library(shiny)

function(input, output, session) {

    dk <- interviewer::buildResponses(
        id = "dk",
        label = "Don't know..."
    )

    continents <-
        interviewer::randomizeResponses(
            interviewer::buildResponses(
                id = c("af", "as", "an", "au", "eu", "na", "sa"),
                label = c("Africa", "Asia", "Antarctica", "Australia", "Europe", "North America", "South America")
            )
        )

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Interviewer DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows a relatively complete set of <strong>interviewer</strong> questions and options.</p>")
            ),

            interviewer::question.single(
                id = "Sex",
                label = "Please enter your sex:",
                responses = interviewer::buildResponses(
                    id = c("m", "f"),
                    label = c("male", "female")
                )
            ),

            interviewer::question.single(
                id = "Age",
                label = "Please enter your age:",
                responses = interviewer::buildResponses(
                    id = c("<=20", "21-30", "31-40", ">40"),
                    label = c("20 or younger", "21 to 30", "31 to 40", "older than 40")
                ),
                use.select = TRUE
            ),

            interviewer::pageBreak(),

            interviewer::question.single(
                id = "MaritalStatus",
                label = "What is your marital status?",
                responses = interviewer::buildResponses(
                    id = c("s", "m", "o"),
                    label = c("single", "married", "other")
                ),
                required = FALSE
            ),

            interviewer::question.multiple(
                id = "Owns",
                label = "Select, from the list, all items that you own:",
                responses = interviewer::buildResponses(
                    id = c("sph", "t", "lt", "dt"),
                    label = c("smartphone", "tablet", "laptop", "desktop")
                ),
                use.select = TRUE,
                required = FALSE
            ),

            interviewer::pageBreak(),

            interviewer::question.multiple(
                id = "Pets",
                label = "What pets do you have?",
                responses = interviewer::buildResponses(
                    id = c("c", "d", "s"),
                    label = c("cat", "dog", "spider")
                ),
                required = FALSE
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
            ),

            interviewer::pageBreak(),

            # Custom question:
            interviewer::buildQuestion(
                id = "Chart",
                dataIds = paste0("Price", c(1:12)),
                ui = function() {
                    priceInput <- function(month) {
                        questionInputId <- interviewer::makeQuestionInputId(paste0("Price", month))
                        shiny::numericInput(inputId = questionInputId,
                                            label = month.abb[month],
                                            min = 1,
                                            max = 1000,
                                            value = shiny::isolate(input[[questionInputId]]))
                    }

                    list(
                        shiny::tags$label("Enter the product's price for each month of last year:"),
                        shiny::p(),
                        shiny::div(
                            shiny::fluidRow(
                                shiny::column(3, lapply(1:6, function(month) priceInput(month))),
                                shiny::column(3, lapply(7:12, function(month) priceInput(month))),
                                shiny::column(6,
                                              shiny::fluidRow(
                                                  shiny::column(6, shiny::plotOutput(outputId = "questionPricePlot")),
                                                  shiny::column(6, shiny::plotOutput(outputId = "questionPriceBoxplot"))
                                              )
                                )
                            )
                        )
                    )
                },
                validate = function() {
                    result <- ""
                    prices <- getPrices(convert.na = FALSE)

                    if (is.null(checkedPrices) || !identical(checkedPrices, prices)) {
                        stats <- boxplot.stats(prices$value)
                        checkedPrices <<- prices

                        if ((stats$n > 6) && (length(stats$out) > 0)) {
                            result <- paste0(
                                "Please double-check the data; it seems some entries are inconsistent with the rest.<br />",
                                "Possibly suspect values: ", paste(stats$out, collapse = ", "), ".<br />",
                                "Click Next where you are happy with the data.")
                        }
                    }

                    result
                }
            ),

            interviewer::pageBreak(),

            interviewer::question.text(
                id = "Nick",
                label = "What's your nickname?"
            ),

            interviewer::question.text(
                id = "Phone",
                label = "What is your phone number? [ddd ddd-ddd]",
                regex = "^\\d{3} \\d{3}-\\d{3}$",
                regexHint = "ddd ddd-ddd"
            ),

            interviewer::buildNonQuestion(
                ui = shiny::HTML("<p>Now, before you answer the next question,<br />please take a moment to think...</p>")
            ),

            interviewer::question.text(
                id = "Comment",
                label = "Anything you want to add?",
                use.textArea = TRUE
            ),

            interviewer::pageBreak(),

            interviewer::buildNonQuestion(
                ui = shiny::p("The question below has responses ordered randomly (except for the last response).")
            ),

            interviewer::question.mixed(
                id = "Continents1",
                label = "Which continents have you ever been to?",
                responses = interviewer::mergeResponses(continents, dk),
                types = c(
                    rep(interviewer::mixedOptions.multiple, nrow(continents)),
                    interviewer::mixedOptions.single
                )
            ),

            interviewer::pageBreak(),

            interviewer::buildNonQuestion(
                ui = shiny::p("The question below displays only those responses that were mentioned in the question on the previous page.")
            ),

            interviewer::question.mixed(
                id = "Continents2a",
                label = "Which continents would you like to visit again?",
                responses = function() {
                    interviewer::mergeResponses(
                        interviewer::maskResponses(continents, "Continents1", operation = "keep"),
                        dk
                    )
                },
                types = function() {
                    continentCount <- nrow(interviewer::maskResponses(continents, "Continents1", operation = "keep"))
                    c(
                        rep(interviewer::mixedOptions.multiple, continentCount),
                        interviewer::mixedOptions.single
                    )
                }
            ),

            interviewer::buildNonQuestion(
                ui = shiny::p("The question below displays only those responses that were not mentioned in the question on the previous page.")
            ),

            interviewer::question.mixed(
                id = "Continents2b",
                label = "Which continents would you still like to visit?",
                responses = function() {
                    interviewer::mergeResponses(
                        interviewer::maskResponses(continents, "Continents1", operation = "drop"),
                        dk
                    )
                },
                types = function() {
                    continentCount <- nrow(interviewer::maskResponses(continents, "Continents1", operation = "drop"))
                    c(
                        rep(interviewer::mixedOptions.multiple, continentCount),
                        interviewer::mixedOptions.single
                    )
                }
            ),

            interviewer::pageBreak(),

            interviewer::question.single(
                id = "Like",
                label = "Did you like the questionnaire?",
                responses = interviewer::buildResponses(
                    id = c("y", "n"),
                    label = c("Yes", "No")
                )
            ),

            goodbye = "Done!",
            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

    checkedPrices <- NULL

    getPrices <- function(convert.na) {
        ifNULLThenNA <- function(value) {
            if (is.null(value)) {
                value <- NA
            }

            value
        }

        prices <- data.frame(value = integer(0))

        for (month in 1:12) {
            questionInputId <- makeQuestionInputId(paste0("Price", month))
            prices[month, "value"] <- ifNULLThenNA(input[[questionInputId]])
        }

        prices
    }

    output$questionPricePlot <- shiny::renderPlot({
        prices <- getPrices(convert.na = FALSE)

        if (length(which(!is.na(prices$value))) > 0) {
            par(mar = c(2, 0, 3, 0))
            plot(prices$value,
                 type = "b",
                 xlab = "",
                 ylab = "")
        }
    })

    output$questionPriceBoxplot <- shiny::renderPlot({
        prices <- getPrices(convert.na = FALSE)
        stats <- boxplot.stats(prices$value)

        if (stats$n > 0) {
            par(mar = c(2, 0, 3, 0))
            boxplot(prices$value)
        }
    })

}
