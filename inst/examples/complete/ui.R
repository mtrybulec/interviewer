library(interviewer)
library(shiny)
library(shinyjs)

fluidPage(
    useShinyjs(), # ToDo: can this be pulled into userInterviewer()?
    useInterviewer(),
    fluidPage(
        uiOutput(outputId = "questionnaireOutput")
    )
)
