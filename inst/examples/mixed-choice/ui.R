library(interviewer)
library(shiny)

shiny::fluidPage(
    interviewer::useInterviewer(),
    shiny::uiOutput(outputId = "questionnaireOutput")
)
