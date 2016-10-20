library(interviewer)
library(shiny)

shiny::fluidPage(
    interviewer::useInterviewer(),
    shiny::h2("mixedOptionsInput example"),
    shiny::hr(),
    shiny::uiOutput(outputId = "questionnaireOutput"),
    shiny::uiOutput(outputId = "dataOutput")
)
