library(interviewer)
library(shiny)

function(input, output, session) {

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Custom question DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>custom</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),

            interviewer::buildNonQuestion(
                ui = list(
                    shiny::p("The question consists of 12 Shiny numericInput elements."),
                    shiny::p("On the right, the entered values will be shown on two plots:
                             a line plot of data by months and a box plot showing any outliers."),
                    shiny::p("If any outliers are found (using boxplot.stats()), the validation code will ask the user to review the data."),
                    shiny::p("Then, after any of the values are changed, the validation code will execute again (possibly asking to review the updated data).
                             But if the data is not changed, a click on Next will accept the data regardless of the validator."),
                    shiny::hr()
                )
            ),

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
