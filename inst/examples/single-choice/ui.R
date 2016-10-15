library(interviewer)
library(shiny)
library(shinyjs)

fluidPage(
    useInterviewer(),
    useShinyjs(), # ToDo: can this be pulled into userInterviewer()?
    fluidPage(
        uiOutput(outputId = "questionnaireOutput")
    )
)
