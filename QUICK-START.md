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

![Simple DEMO](https://github.com/mtrybulec/interviewer/blob/master/img/simple-demo.png "Simple DEMO")

While the texts `"Question 1"` and `"response A"` to `"response C"` will be displayed on the screen,
the data will be saved in the `"q1"` column, and it will be one of the values: `"a"`, `"b"`, or `"c"`.

And that's what the final argument of the `questionnaire` does: `exit` defines a callback function
that will be called when the respondent is done with the interview. The function will be called
with the data.frame that contains the respondent's answers. Here, it just prints the results,
but you may choose to save the data to a database, a file, etc.:

```
Done:
  q1
1  b
```

## Longer questionnaires, splitting questions into pages

Obviously, you can build longer than just one-question questionnaires.
Just add more question definitions in the `...` part of the call to `questionnaire`.

You may also choose to break the questionnaire into pages or screens -
so that the respondent in not overwhelmed when presented with a very long web page.

From now on I'll omit showing the `ui.R` code - it's the same for all examples -
and screenshots of the welcome and goodbye pages.

And, for most examples, we'll define a single response list that can be reused
in multiple questions (which, BTW, shows how R *is* the questionnaire scripting language
and can be used for defining common question elements).

```r
server.R:

library(interviewer)
library(shiny)

function(input, output) {

    responses = interviewer::buildResponses(
        id = c("a", "b", "c"),
        label = c("response A", "response B", "response C")
    )
    
    output$questionnaireOutput <-
        interviewer::questionnaire(
            label = "Simple DEMO",
            welcome = "Welcome",
            goodbye = "Done!",

            interviewer::question.list(
                id = "q1",
                label = "Question 1",
                responses = responses
            ),

            interviewer::question.list(
                id = "q2",
                label = "Question 2",
                responses = responses
            ),

            interviewer::pageBreak(),

            interviewer::question.list(
                id = "q3",
                label = "Question 3",
                responses = responses
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
```

In the above, we have two questions on the first page, and one question on the second page.

![Page DEMO](https://github.com/mtrybulec/interviewer/blob/master/img/page-demo.png "Page DEMO")

You can use the Back and Next buttons to navigate to earlier questions
and then back to the current question.

And the resulting data.frame:

```
Done:
  q1 q2 q3
1  a  b  c
```

## Standard question definitions

Up till now, only simple, single-response questions were shown. However, `interviewer` comes
equipped with several question templates for the most common scenarios
(plus you can build your questions from scratch, but that's for later).

### Validation

All pre-defined question templates take a `required` argument; if it's `TRUE` (default),
the validation function will not let the respondent move to the next page without answering the question.
If it's `FALSE`, the respondent may choose not to select a response (enter a value).

![Validation message](https://github.com/mtrybulec/interviewer/blob/master/img/validation.png "Standard validation")

### Single-choice

Single-choice questions have several options: you can display those as radio-buttons (recommended, default)
or combo-boxes. And if you decide to use radio-buttons, you can display those vertically (default) or inline/horizontally.

```r
server.R - radio-buttons:

            . . .

            interviewer::question.list(
                id = "RadioButtonsStandard",
                label = "Radio-buttons, standard",
                responses = responses
            ),

            interviewer::question.list(
                id = "RadioButtonsInline",
                label = "Radio-buttons, inline (inline set to TRUE)",
                responses = responses,
                inline = TRUE
            ),

            interviewer::question.list(
                id = "RadioButtonsOptional",
                label = paste("Radio-buttons, no response required",
                              "(required set to FALSE; a second click on a selected radio-button deselects it)"),
                responses = responses,
                required = FALSE
            ),

            interviewer::question.list(
                id = "RadioButtonsNarrow",
                label = "Radio-buttons, inline and narrow (width set to '250px')",
                responses = responses,
                inline = TRUE,
                width = "250px"
            ),

            . . .
```            

The first question is just a standard single-choice question as seen earlier.
The second question uses `inline` (horizontal) layout.
The third question sets `required` to `FALSE`, meaning the respondent is free not to answer the question
The final question shows basic styling of the question layout - changing its `width`.

All questions are initially displayed without any pre-selected responses;
the respondent is always free to deselect a response,
even when the question uses radio-buttons.

![Single-choice radio-buttons](https://github.com/mtrybulec/interviewer/blob/master/img/single-choice-radio-buttons.png "Single-choice radio-buttons")

And now, a similar set of questions, but using (single-selection) combo-boxes:

```r
server.R - combo-boxes:
            
            . . .

            interviewer::question.list(
                id = "ComboBoxStandard",
                label = "Combo-box, standard (use.select set to TRUE)",
                responses = responses,
                use.select = TRUE
            ),

            interviewer::question.list(
                id = "ComboBoxPlaceholder",
                label = "Combo-box, custom message (selectizePlaceholder set to 'I need a response!')",
                responses = responses,
                use.select = TRUE,
                selectizePlaceholder = "I need a response!"
            ),

            interviewer::question.list(
                id = "ComboBoxOptional",
                label = "Combo-box, no response required (required set to FALSE)",
                responses = responses,
                use.select = TRUE,
                selectizePlaceholder = "This question is optional",
                required = FALSE
            ),

            interviewer::question.list(
                id = "ComboBoxNarrow",
                label = "Combo-box, narrow (width set to '200px')",
                responses = responses,
                use.select = TRUE,
                width = "200px"
            ),
            
            . . .

```

The first question is just a standard single-choice question,
but sets `use.select` to `TRUE` to display as a combo-box.
The second question uses defines a `placeholder` that will be displayed
in the edit area of the combo-box before any selections are made.
The third question sets `required` to `FALSE`, meaning the respondent is free not to answer the question
The final question shows basic styling of the question layout - changing its `width`.

![Single-choice combo-boxes](https://github.com/mtrybulec/interviewer/blob/master/img/single-choice-combo-boxes.png "Single-choice combo-boxes")

A note on using combo-boxes: they're harder to use (for respondents) 
than radio-buttons - they require two clicks to select a response.
Combo-boxes can also display on top of subsequent questions or navigation buttons,
hiding contents and requiring yet another click outside of the pull-down list.

So, combo-boxes should really be used only when the list of responses is very long
(respondents can then filter the list by typing a part of the response text).

(The above code comes from the `"single-choice"` example - execute `runExample("single-choice")`.)

### Multi-choice

### Mixed-choice

### Text

### Numeric

## Dynamic response lists

In progress, but check out `interviewer` examples using `runExample()`...

## Arbitrary Shiny UI

## Custom question definitions

## Custom question validation

## Questionnaire control-flow

## Navigating backwards and forwards through the questionnaire
