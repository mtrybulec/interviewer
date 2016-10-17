library(interviewer)
library(shiny)

fluidPage(
    useInterviewer(),
    uiOutput(outputId = "questionnaireOutput")
)
