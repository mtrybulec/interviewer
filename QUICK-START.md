# interviewer quick-start

## Basic ui.R and server.R code

An `interviewer` questionnaire is "hosted" in a standard Shiny application - it's just 
a single output item in the `ui.R` file and a single function call in the `server.R` file.
A minimal example follows (all functions are referenced using package names
just to make it clear what comes from which package):

```r
ui.R:

library(interviewer)
library(shiny)

shiny::fluidPage(
    interviewer::useInterviewer(),
    shiny::uiOutput(outputId = "questionnaireOutput")
)
```

```r
server.R:

library(interviewer)
library(shiny)

function(input, output) {

    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Simple DEMO",
            welcome = "Welcome",
            goodbye = "Done!",

            interviewer::question.list(
                id = "q1",
                label = "Question 1",
                responses = interviewer::buildResponses(
                    id = c("a", "b", "c"),
                    label = c("response A", "response B", "response C")
                )
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
```

## Pages and standard question definitions

## Dynamic response lists

## Arbitrary Shiny UI

## Custom question definitions

## Custom question validation

## Arbitrary R code

## Questionnaire control-flow

## Navigating backwards and forwards through the questionnaire

## Getting back questionnaire data
