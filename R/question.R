.question <- function(id, ui, required) {
    list(
        id = id,
        ui = ui,
        required = required
    )
}

#' Define a question that displays a list of possible responses.
#' 
#' \code{question.list} retuns a question definition that displays responses
#' as radio-buttons, check-boxes, or comb-boxes. Can be used for single-
#' and multiple-choice questions.
#' 
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with 'question' - as the \code{inputId} 
#'     for the \code{input} slot.
#' @param label (character) the text displayed as the header of the question.
#' @param responses (data.frame) a listing of the identifiers and labels
#'     of all responses; use \code{ids} and \code{labels} as column names;
#'     each row represents a single response.
#' @param multiple (logical) if \code{FALSE}, defines a single-choice question;
#'     if \code{TRUE}, dfines a multiple-choice question.
#' @param use.select (logical) if \code{FALSE}, displays radio-buttons
#'     for single-choice questions and check-boxes for multiple-choice
#'     questions; if \code{TRUE}, displays a combo-box with all responses available
#'     through the drop-down list.
#' @param required (logical) if \code{FALSE}, the respondent is free to not chose
#'     a response; if \code{TRUE}, the respondent must select a response before 
#'     moving on to subsequent pages of the questionnaire.
#' @param inline (logical) if \code{FALSE}, radio-buttons and check-boxes will be 
#'     displayed vertically; if \code{TRUE}, controls will be displayed horizontally.
#'     If \code{use.select == TRUE}, this parameter will be ignored.
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'}.
#' @param selectizePlaceholder (character) the text that will be displayed
#'     in the combo-box when there are no responses selected yet; defaults to
#'     \code{"Click to select a response"} for single-choice questions and
#'     \code{"Click to select responses"} for multiple-choice questions.
#'     If \code{use.select == FALSE}, this parameter will be ignored.
#' @param selectizeOptions (list) a list of selectize options as documented
#'     in \code{\link[shiny]{selectInput}}. If defined, it overrides \code{selectizePlaceholder}.
#'
#' @family question definitions
#' @seealso
#'     \code{\link[shiny]{checkboxGroupInput}}, 
#'     \code{\link[shiny]{radioButtons}},
#'     \code{\link[shiny]{selectInput}}.
#' @export
question.list <- function(id, label, responses, multiple = FALSE, use.select = FALSE, required = TRUE, inline = FALSE,
                          width = NULL, selectizePlaceholder = NULL, selectizeOptions = NULL) {
    if (!use.select && !is.null(selectizePlaceholder)) {
        warning("selectizePlaceholder ignored - use.select is FALSE.")
    }
    if (!use.select && !is.null(selectizeOptions)) {
        warning("selectizeOptions ignored - use.select is FALSE.")
    }
    if (!is.null(selectizePlaceholder) && !is.null(selectizeOptions)) {
        warning("selectizePlaceholder ignored - selectizeOptions takes precedence.")
    }
    if (inline && use.select) {
        warning("inline ignored - use.select takes precedence.")
    }
    
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    
    questionId <- .questionId(id)
    
    choices <- as.character(responses$ids) 
    names(choices) <- responses$labels

    selected <- isolate(input[[questionId]])
    
    ui <- function(context) {
        if (multiple && !use.select) {
            shiny::checkboxGroupInput(
                choices = choices,
                inline = inline,
                inputId = questionId, 
                label = label, 
                selected = selected,
                width = width
            )
        } else if (use.select) {
            if (is.null(selectizeOptions)) {
                if (is.null(selectizePlaceholder)) {
                    if (multiple) {
                        selectizePlaceholder <- "Click to select responses"
                    } else {
                        selectizePlaceholder <- "Click to select a response"
                    }  
                } 

                selectizeOptions <- list(
                    placeholder = selectizePlaceholder, 
                    plugins = list("remove_button")
                )
            } 
            
            if (!multiple) {
                choices <- c(selectizePlaceholder = .emptyResponseValue, choices)
            }

            shiny::selectizeInput(
                choices = choices,
                inputId = questionId, 
                label = label,
                multiple = multiple,
                options = selectizeOptions,
                selected = selected,
                width = width
            )
        } else {
            if (is.null(selected)) {
                # Don't pre-select responses; see also main.js code that handles radio-button unchecking.
                selected <- character(0)
            }
            
            shiny::radioButtons(
                choices = choices,
                inline = inline,
                inputId = questionId, 
                label = label, 
                selected = selected,
                width = width
            )
        }
    }
    
    .question(id, ui, required)
}

#' @export
question.numeric <- function(id, label, min, max, use.slider = FALSE, required = TRUE) {
    questionId <- .questionId(id)

    ui <- function(context) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        if (use.slider) {
            shiny::sliderInput(
                inputId = questionId, 
                label = label,
                min = min,
                max = max,
                value = isolate(input[[questionId]])
            )
        } else {
            shiny::numericInput(
                inputId = questionId, 
                label = label,
                min = min,
                max = max,
                value = isolate(input[[questionId]])
            )
        }
    }

    .question(id, ui, required)
}

# http://stackoverflow.com/questions/14452465/how-to-create-textarea-as-input-in-a-shiny-webapp-in-r
#' @export
question.text <- function(id, label, cols = 80, rows = 1, required = TRUE) {
    questionId <- .questionId(id)
    
    ui <- function(context) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        shiny::tags$div(class = "form-group shiny-input-container",
            shiny::tags$label("for" = questionId, label),
            shiny::tags$textarea(
                id = questionId, 
                class = "form-control",
                rows = rows, 
                cols = cols,
                isolate(input[[questionId]]))
        )
    }

    .question(id, ui, required)
}
