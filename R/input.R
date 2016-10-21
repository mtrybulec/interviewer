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

#' Get the single (mutually-exclusive) option type for \code{mixedOptionsInput}.
#'
#' Returns the single (mutually-exclusive) option type for \code{mixedOptionsInput}'s \code{types} parameter.
#'
#' @family mixedOptionsInput option types
#' @seealso
#'     \code{\link{mixedOptionsInput}}.
#' @export
mixedOptions.single <- "radio"

#' Get the multiple (non-mutually-exclusive) option type for \code{mixedOptionsInput}.
#'
#' Returns the multiple (non-mutually-exclusive) option type for \code{mixedOptionsInput}'s \code{types} parameter.
#'
#' @family mixedOptionsInput option types
#' @seealso
#'     \code{\link{mixedOptionsInput}}.
#' @export
mixedOptions.multi <- "checkbox"

#' Define an input field with both radio-buttons and check-boxes.
#'
#' \code{mixedOptionsInput} creates a set of radio-buttons and check-boxes.
#'     Check-boxes can be used to toggle multiple choices indepdenently,
#'     while radio-buttons can be used to define additional, mutually exclusive options.
#'
#' @param inputId (character) the \code{input} slot that will be used to access the value.
#' @param label (character) display label for the control, or \code{NULL} for no label.
#' @param choices (list) list of values to show radio-buttons and check-boxes for;
#'     if elements of the list are named then that name, rather than the value,
#'     will be displayed to the user.
#' @param selected (vector) the values that should be initially selected, if any.
#' @param inline (logical) if \code{TRUE}, render the choices inline (i.e. horizontally).
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'};
#'     see \code{\link[shiny]{validateCssUnit}}.
#'
#' @seealso
#'     \code{\link{question.mixed}},
#'     \code{\link[shiny]{checkboxGroupInput}},
#'     \code{\link[shiny]{radioButtons}}.
#' @export
mixedOptionsInput <- function(inputId, label, choices, types, selected = NULL, inline = FALSE, width = NULL) {
    if (length(choices) != length(types)) {
        stop("Different choice and type counts.")
    }

    selected <- shiny::restoreInput(id = inputId, default = selected)

    if (is.null(selected)) {
        selected <- character(0)
    }

    options <- generateMixedOptions(inputId, choices, types, selected, inline)

    divClass <- "form-group interviewer-mixedoptionsgroup shiny-input-container"

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
