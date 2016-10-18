.question <- function(id, ui, required, validate = NULL) {
    list(
        id = id,
        ui = ui,
        required = required,
        validate = validate
    )
}

#' Define a question that displays a list of possible responses.
#' 
#' \code{question.list} retuns a question definition that displays responses
#' as radio-buttons, check-boxes, or combo-boxes. Can be used for single-
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
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before 
#'     moving on to subsequent pages of the questionnaire.
#' @param use.select (logical) if \code{FALSE}, displays radio-buttons
#'     for single-choice questions and check-boxes for multiple-choice
#'     questions; if \code{TRUE}, displays a combo-box with all responses available
#'     through the drop-down list.
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
question.list <- function(id, label, responses, multiple = FALSE, required = TRUE, use.select = FALSE, inline = FALSE,
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
    
    questionId <- .questionId(id)
    
    choices <- as.character(responses$ids) 
    names(choices) <- responses$labels

    ui <- function(context) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        selected <- shiny::isolate(input[[questionId]])

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

#' Define a question that allows the selection of numeric values.
#' 
#' \code{question.numeric} retuns a question definition that uses
#' an input line with a spinner or a slider control for entry of numeric values.
#' 
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with 'question' - as the \code{inputId} 
#'     for the \code{input} slot.
#' @param label (character) the text displayed as the header of the question.
#' @param min (numeric) minimum allowed value.
#' @param max (numeric) maximum allowed value.
#' @param step (numeric) interval to use when stepping between \code{min} and \code{max}.
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before 
#'     moving on to subsequent pages of the questionnaire.
#'     If \code{use.slider == TRUE}, this parameter will be ignored.
#' @param use.slider (logical) if \code{FALSE}, displays an input line 
#'     with a spinner to increase/decrease the value; if \code{TRUE},
#'     displays a slider control.
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'}.
#'     
#' @family question definitions
#' @seealso
#'     \code{\link[shiny]{numericInput}},
#'     \code{\link[shiny]{sliderInput}}.
#' @export
question.numeric <- function(id, label, min, max, step = NA, required = TRUE, use.slider = FALSE, width = NULL) {
    if (use.slider && !required) {
        warning("required ignored - use.slider forces a selection of a value.")
    }
    if (min >= max) {
        warning("min >= max.")
    } else if (!missing(step) && (step > max - min)) {
        warning("step > max - min.")
    }
    
    questionId <- .questionId(id)
    
    ui <- function(context) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input
        
        value <- shiny::isolate({
            result <- input[[questionId]]
            
            if (is.null(result) && use.slider) {
                result <- min
            }
            
            result
        })

        if (use.slider) {
            shiny::sliderInput(
                dragRange = FALSE, # set so that the mouse cursor doesn't change to a resize arrow
                inputId = questionId, 
                label = label,
                min = min,
                max = max,
                step = step,
                value = value,
                width = width
            )
        } else {
            shiny::numericInput(
                inputId = questionId, 
                label = label,
                min = min,
                max = max,
                step = step,
                value = value,
                width = width
            )
        }
    }
    
    question <- .question(id, ui, required)

    question$validate <- function() {
        result <- .validateIsAnswered(question)

        if (result == .validResult) {
            domain <- shiny::getDefaultReactiveDomain()
            input <- domain$input

            value <- input[[questionId]]

            if (.isAnswered(value)) {
                if (value < min || value > max) {
                    result <- sprintf("Value out of bounds (%g..%g).", min, max)
                }
            }
        }
        
        result
    }

    question
}

#' @export
question.text <- function(id, label, required = TRUE, width = NULL, height = NULL, cols = 80, rows = 1, placeholder = NULL) {
    questionId <- .questionId(id)
    
    ui <- function(context) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        shiny::textAreaInput(
            cols = cols,
            height = height,
            inputId = questionId,
            label = label,
            placeholder = placeholder,
            rows = rows,
            value = shiny::isolate(input[[questionId]]),
            width = width
        )
    }

    .question(id, ui, required)
}
