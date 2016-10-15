.question <- function(id, ui, required) {
    list(
        id = id,
        ui = ui,
        required = required
    )
}

#' @export
question.list <- function(id, label, responses, multiple = FALSE, displayList = FALSE, required = TRUE, inline = FALSE, 
                          selectizePlaceholder = NULL, selectizePlugins = list("remove_button"), width = NULL) {
    
    questionId <- .questionId(id)
    
    choices <- as.character(responses$ids) 
    names(choices) <- responses$labels

    if (displayList && is.null(selectizePlaceholder)) {
        if (multiple) {
            selectizePlaceholder <- "Click to select responses"
        } else {
            selectizePlaceholder <- "Click to select a response"
        }  
    } 
    
    ui <- function(context) {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        if (multiple && !displayList) {
            shiny::checkboxGroupInput(
                inputId = questionId, 
                label = label, 
                choices = choices,
                selected = isolate(input[[questionId]])
            )
        } else if (displayList) {
            if (!multiple) {
                choices <- c(selectizePlaceholder = .emptyResponseValue, choices)
            }

            shiny::selectizeInput(
                choices = choices,
                inputId = questionId, 
                label = label,
                multiple = multiple,
                options = list(
                    placeholder = selectizePlaceholder, 
                    plugins = selectizePlugins
                ),
                selected = isolate(input[[questionId]]),
                width = width
            )
        } else {
            selected <- isolate(input[[questionId]])

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
