library(interviewer)
library(shiny)
library(shinyjs)

fluidPage(
    useInterviewer(),
    fluidPage(
        uiOutput(outputId = "questionnaireOutput")
    )
)
