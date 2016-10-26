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

The code above uses Shiny's `fluidPage` but any other layout function could be used as well.

`useInterviewer` must be called at least once to set up `interviewer`-specific CSS and JavaScript.
And since `interviewer` uses the `shinyjs` package, it calls its `useShinyjs` method as well.

The second instructions defines the output field where all generated questionnaire output
will be displayed. Since it's just one output field, you can add any other valid Shiny output
before or after `interviewer` code.

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

The `questionnaire` call above defines the title of the survey that will be displayed
at the top of the output field. Next, it defines two pages: a `welcome` page and a `goodbye` page
that will be displayed before the interview starts and after it ends. Here, this is just text,
but it can be any valid Shiny output.

Next come a series of questions, UI elements, page-breaks, and function definitions
that make up the full questionnaire definition. Here, it's a single, single-choice question,
that displays `"Question 1"` as its label, and displays three responses (in this case, using radio-buttons).

While the `buildResponses` function is called here to construct response ids and labels,
this is just a standard R data.frame. As such, you can construct this data.frame using
whatever R code you'd like to use (including things like randomization of responses).
`buildResponses` is just a helper function like some other question and response helper functions.

[Simple DEMO]((https://github.com/mtrybulec/interviewer/blob/master/img/simple-demo.png "Simple DEMO")

While the texts `"Question 1"` and `"response A"` to `"response C"` will be displayed on the screen,
the data will be saved in the `"q1"` column, and it will be one of the values: `"a"`, `"b"`, or `"c"`.

And that's what the final argument of the `questionnaire` function does: `exit` defines a callback function
that will be called when the respondent is done with the interview. The function will be called
with the data.frame that contains the respondent's answers. Here, it just prints the results:

```
Done:
  q1
1  b
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
