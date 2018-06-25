library(shiny)

function(input, output, session) {

    responses <- interviewer::buildResponses(
        id = c("a", "b", "c", "d", "e", "f", "g"),
        label = c("response A", "response B", "response C", "response D", "response E", "response F", "response G")
    )

    mixedChoices <- as.character(responses$id)
    names(mixedChoices) <- responses$label
    mixedTypes <- c(
        rep(interviewer::mixedOptions.multiple, 3),
        rep(interviewer::mixedOptions.single, 2),
        interviewer::mixedOptions.multiple,
        interviewer::mixedOptions.single
    )

    output$questionnaireOutput <- shiny::renderUI({
        list(
            interviewer::mixedOptionsInput(
                inputId = "MixedStandard",
                label = "Mixed, standard",
                choices = mixedChoices,
                types = mixedTypes,
                selected = c("a","b")
            ),
            interviewer::mixedOptionsInput(
                inputId = "MixedInline",
                label = "Mixed, inline (inline set to TRUE)",
                choices = mixedChoices,
                types = mixedTypes,
                inline = TRUE,
                selected = "e"
            )
        )
    })

    output$dataOutput <- shiny::renderUI({
        list(
            shiny::hr(),
            shiny::p(shiny::strong("Data returned by the mixedOptionsInput fields:")),
            shiny::p(),
            shiny::p(paste0("1: [", paste(input$MixedStandard, collapse = ", "), "]")),
            shiny::p(paste0("2: [", paste(input$MixedInline, collapse = ", "), "]"))
        )
    })

}
