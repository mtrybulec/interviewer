# The code below is based on the generateOptions function from Shiny:
generateMixedOptions <- function(inputId, choices, types, selected, inline) {
    options <- mapply(
        choices,
        names(choices),
        types,
        FUN = function(value, name, type) {
            inputTag <- shiny::tags$input(
                name = inputId,
                type = type,
                value = value
            )

            if (value %in% selected) {
                inputTag$attribs$checked <- "checked"
            }

            if (inline) {
                shiny::tags$label(
                    class = paste0(type, "-inline"),
                    inputTag,
                    shiny::span(name)
                )
            } else {
                shiny::div(
                    class = type,
                    shiny::tags$label(inputTag, tags$span(name))
                )
            }
        },
        SIMPLIFY = FALSE,
        USE.NAMES = FALSE
    )

    shiny::div(
        class = "shiny-options-group",
        options
    )
}

#' @export
mixedOptionsInput <- function(inputId, label, choices, types, selected = NULL, inline = FALSE, width = NULL) {
    selected <- shiny::restoreInput(id = inputId, default = selected)

    if (is.null(selected)) {
        selected <- character(0)
    }

    options <- generateMixedOptions(inputId, choices, types, selected, inline)

    divClass <- "form-group shiny-input-radiogroup shiny-input-checkboxgroup interviewer-mixedoptionsgroup shiny-input-container"

    if (inline) {
        divClass <- paste(divClass, "shiny-input-container-inline")
    }

    if (is.null(width)) {
        divStyle <- NULL
    } else {
        divStyle <- paste0("width: ", shiny::validateCssUnit(width), ";")
    }

    shiny::div(
        id = inputId,
        style = divStyle,
        class = divClass,
        shiny::tags$label(
            class = "control-label",
            `for` = inputId,
            label
        ),
        options
    )
}
