.question <- "question"
.questionStatus  <- "questionStatus"

#' Define a question input identifier.
#'
#' \code{makeQuestionInputId} returns a standard question identifier used
#' for defining input fields.
#'
#' @param id (character) the unique identifier of the question;
#'     it will be prefixed with \code{'question'} to create the \code{inputId}
#'     for the \code{input} slot. Only input fields
#'     with the \code{'question'} prefix will be returned in the final data.frame.
#'
#'     For use only when defining questions from scratch. When using question
#'     building functions, use the question identifier only.
#'
#' @family question buidling functions
#' @seealso
#'     \code{\link{question.mixed}},
#'     \code{\link{question.multiple}},
#'     \code{\link{question.numeric}},
#'     \code{\link{question.single}},
#'     \code{\link{question.text}}.
#' @export
makeQuestionInputId <- function(id) {
    paste0(.question, id)
}

.questionStatusId <- function(id) {
    paste0(.questionStatus, id)
}

#' Build a question definition from scratch.
#'
#' \code{buildQuestion} returns a question definition given the parts
#'     a fully formed question definition consists of.
#'
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with \code{'question'} - as the \code{inputId}
#'     for the \code{input} slot.
#' @param dataIds (character) the list of identifiers that should be
#'     moved from the \code{input} slot to the final data.frame.
#'
#'     When a question definition consists of multiple input fields,
#'     this argument needs to specify the identifiers of those fields.
#' @param ui (list|function) a list of UI components of the question or
#'     a function that should return the UI components of the question.
#'     Use a list to build static content and a function to build dynamic content.
#' @param validate (function) a function that should return
#'     an empty string if the entered data is valid and a non-empty string,
#'     with the validation message, if the entered data is not valid.
#'
#' @family question buidling functions
#' @seealso
#'     \code{\link{buildNonQuestion}},
#'     \code{\link{question.mixed}},
#'     \code{\link{question.multiple}},
#'     \code{\link{question.numeric}},
#'     \code{\link{question.single}},
#'     \code{\link{question.text}}.
#' @export
buildQuestion <- function(id, dataIds = id, ui, validate = NULL) {
    list(
        id = id,
        dataIds = dataIds,
        type = .question,
        ui = ui,
        validate = validate
    )
}

#' Define a single-choice question.
#'
#' \code{question.single} returns a question definition that displays responses
#' as radio-buttons or as a combo-box, allowing for the selection of at most one response.
#'
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with \code{'question'} - as the \code{inputId}
#'     for the \code{input} slot.
#' @param label (character) the text displayed as the header of the question.
#' @param responses (response list) the response list giving the identifiers and labels
#'     of all responses (e.g. as returned by \code{\link{buildResponses}}).
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before
#'     moving on to subsequent pages of the questionnaire.
#' @param use.select (logical) if \code{FALSE}, displays radio-buttons;
#'     if \code{TRUE}, displays a combo-box with all responses available
#'     through the drop-down list.
#' @param inline (logical) if \code{FALSE}, radio-buttons will be displayed vertically;
#'     if \code{TRUE}, controls will be displayed horizontally.
#'     If \code{use.select == TRUE}, this argument will be ignored.
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'}.
#' @param placeholder (character) the text that will be displayed
#'     in the combo-box when there are no responses selected yet;
#'     defaults to \code{"Click to select a response"}.
#'     If \code{use.select == FALSE}, this argument will be ignored.
#'
#' @family question definitions
#' @seealso
#'     \code{\link{buildResponses}},
#'     \code{\link[shiny]{checkboxGroupInput}},
#'     \code{\link[shiny]{radioButtons}},
#'     \code{\link[shiny]{selectInput}}.
#' @export
question.single <- function(id, label, responses, required = TRUE,
                            use.select = FALSE, inline = FALSE, width = NULL, placeholder = NULL) {
    interviewer::question.mixed(id, label, responses, interviewer::mixedOptions.single, required,
                                use.select, inline, width, placeholder)
}

#' Define a multiple-choice question.
#'
#' \code{question.multiple} returns a question definition that displays responses
#' as check-boxes or as a combo-box, allowing for the selection of multiple responses.
#'
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with \code{'question'} - as the \code{inputId}
#'     for the \code{input} slot.
#'     Note: multiple responses will be coded in a single data.frame column
#'     as comma-separated response identifiers.
#' @param label (character) the text displayed as the header of the question.
#' @param responses (response list) the response list giving the identifiers and labels
#'     of all responses (e.g. as returned by \code{\link{buildResponses}}).
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before
#'     moving on to subsequent pages of the questionnaire.
#' @param use.select (logical) if \code{FALSE}, displays check-boxes;
#'     if \code{TRUE}, displays a combo-box with all responses available
#'     through the drop-down list.
#' @param inline (logical) if \code{FALSE}, check-boxes will be displayed vertically;
#'     if \code{TRUE}, controls will be displayed horizontally.
#'     If \code{use.select == TRUE}, this argument will be ignored.
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'}.
#' @param placeholder (character) the text that will be displayed
#'     in the combo-box when there are no responses selected yet;
#'     defaults to \code{"Click to select responses"}.
#'     If \code{use.select == FALSE}, this argument will be ignored.
#'
#' @family question definitions
#' @seealso
#'     \code{\link{buildResponses}},
#'     \code{\link[shiny]{checkboxGroupInput}},
#'     \code{\link[shiny]{radioButtons}},
#'     \code{\link[shiny]{selectInput}}.
#' @export
question.multiple <- function(id, label, responses, required = TRUE,
                              use.select = FALSE, inline = FALSE, width = NULL, placeholder = NULL) {
    interviewer::question.mixed(id, label, responses, interviewer::mixedOptions.multiple, required,
                                use.select, inline, width, placeholder)
}

#' Define a question that displays a list of mixed single- and multiple-choice responses.
#'
#' \code{question.mixed} returns a question definition that displays responses
#' as a mix of radio-buttons and check-boxes, or as a combo-box.
#' Can be used for defining multiple-choice questions with responses
#' such as "none of the above" or "don't know".
#'
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with \code{'question'} - as the \code{inputId}
#'     for the \code{input} slot.
#' @param label (character) the text displayed as the header of the question.
#' @param responses (response list) the response list giving the identifiers and labels
#'     of all responses (e.g. as returned by \code{\link{buildResponses}}).
#' @param types (character) the types of responses; use \code{'radio'}
#'     for radio-buttons (single-choice / mutually exclusive responses) and
#'     \code{'checkbox'} for check-boxes (multiple-choice responses).
#'     The length of this vector must be the same as the number of responses defined in \code{responses}.
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before
#'     moving on to subsequent pages of the questionnaire.
#' @param use.select (logical) if \code{FALSE}, displays radio-buttons and check-boxes;
#'     if \code{TRUE}, displays a combo-box with all responses available
#'     through the drop-down list.
#' @param inline (logical) if \code{FALSE}, radio-buttons and check-boxes will be
#'     displayed vertically; if \code{TRUE}, controls will be displayed horizontally.
#'     If \code{use.select == TRUE}, this argument will be ignored.
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'}.
#' @param placeholder (character) the text that will be displayed
#'     in the combo-box when there are no responses selected yet; defaults to
#'     \code{"Click to select a response"} for single-choice questions (with all responses mutually exclusive) and
#'     \code{"Click to select responses"} otherwise.
#'     If \code{use.select == FALSE}, this argument will be ignored.
#'
#' @family question definitions
#' @seealso
#'     \code{\link{buildResponses}},
#'     \code{\link{mixedOptionsInput}},
#'     \code{\link[shiny]{selectInput}}.
#' @export
question.mixed <- function(id, label, responses, types, required = TRUE, use.select = FALSE, inline = FALSE,
                           width = NULL, placeholder = NULL) {
    force(names(as.list(environment())))

    if (!use.select && !is.null(placeholder)) {
        warning("placeholder ignored - use.select is FALSE.")
    }
    if (inline && use.select) {
        warning("inline ignored - use.select takes precedence.")
    }

    ui <- function() {
        questionInputId <- makeQuestionInputId(id)

        if (class(responses) == "function") {
            responses <- responses()
        }
        choices <- as.character(responses$id)
        names(choices) <- responses$label

        if (class(types) == "function") {
            types <- types()
        } else if (length(types) == 1) {
            types <- rep(types[1], nrow(responses))
        }

        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        selected <- shiny::isolate(input[[questionInputId]])

        if (use.select) {
            if (is.null(placeholder)) {
                if ((length(unique(types)) == 1) && (types[1] == mixedOptions.single)) {
                    placeholder <- "Click to select a response"
                } else {
                    placeholder <- "Click to select responses"
                }
            }

            mutexOptions <- choices[which(types == mixedOptions.single)]
            mutexOptions <- paste(paste0('"', gsub('"', '\\"', mutexOptions), '"'), collapse = ', ')

            options <- list(
                placeholder = placeholder,
                plugins = list("remove_button"),
                onInitialize = I(sprintf("
function() {
    this.mutexOptions = [%s];
}
", mutexOptions)),
                onItemAdd = I("
function(value, $item) {
    if ((this.items.length > 0) && (this.items[0] != value)) {
        if ((this.mutexOptions.indexOf(value) != -1) || (this.mutexOptions.indexOf(this.items[0]) != -1)) {
            this.setValue(value, false);
        }
    }

    if ((this.items.length == 1) && (this.items[0] == value) && (this.mutexOptions.indexOf(value) != -1)) {
        this.close();
    }
}")
            )

            shiny::selectizeInput(
                choices = choices,
                inputId = questionInputId,
                label = label,
                multiple = TRUE,
                options = options,
                selected = selected,
                width = width
            )
        } else {
            interviewer::mixedOptionsInput(
                choices = choices,
                inline = inline,
                inputId = questionInputId,
                label = label,
                selected = selected,
                types = types,
                width = width
            )
        }
    }

    question <- buildQuestion(id = id, ui = ui)

    question$validate <- function() {
        .validateIsAnswered(question, required)
    }

    question
}

#' Define a question that allows the selection of numeric values.
#'
#' \code{question.numeric} returns a question definition that uses
#' an input line with a spinner or a slider control for entry of numeric values.
#'
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with \code{'question'} - as the \code{inputId}
#'     for the \code{input} slot.
#' @param label (character) the text displayed as the header of the question.
#' @param min (numeric) minimum allowed value.
#' @param max (numeric) maximum allowed value.
#' @param step (numeric) interval to use when stepping between \code{min} and \code{max}.
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before
#'     moving on to subsequent pages of the questionnaire.
#'     If \code{use.slider == TRUE}, this argument will be ignored.
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
    force(names(as.list(environment())))

    if (use.slider && !required) {
        warning("required ignored - use.slider forces a selection of a value.")
    }
    if (min >= max) {
        warning("min >= max.")
    } else if (!missing(step) && (step > max - min)) {
        warning("step > max - min.")
    }

    questionInputId <- makeQuestionInputId(id)

    ui <- function() {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        value <- shiny::isolate({
            result <- input[[questionInputId]]

            if (is.null(result) && use.slider) {
                result <- min
            }

            result
        })

        if (use.slider) {
            shiny::sliderInput(
                dragRange = FALSE, # set so that the mouse cursor doesn't change to a resize arrow
                inputId = questionInputId,
                label = label,
                min = min,
                max = max,
                step = step,
                value = value,
                width = width
            )
        } else {
            shiny::numericInput(
                inputId = questionInputId,
                label = label,
                min = min,
                max = max,
                step = step,
                value = value,
                width = width
            )
        }
    }

    question <- buildQuestion(id = id, ui = ui)

    question$validate <- function() {
        result <- .validateIsAnswered(question, required)

        if (result == .validResult) {
            domain <- shiny::getDefaultReactiveDomain()
            input <- domain$input

            value <- input[[questionInputId]]

            if (.isAnswered(value) && (value < min || value > max)) {
                result <- sprintf("Value out of bounds (%g..%g).", min, max)
            }
        }

        result
    }

    question
}

#' Define a question that allows text entry.
#'
#' \code{question.text} returns a question definition that uses
#' an input line or text area for entry of text values.
#'
#' @param id (character) the unique identifier of the question; it will be used
#'     as the column name in the data.frame returning the questionnaire data
#'     and when prefixed with \code{'question'} - as the \code{inputId}
#'     for the \code{input} slot.
#' @param label (character) the text displayed as the header of the question.
#' @param required (logical) if \code{FALSE}, the respondent is free to not choose
#'     a response; if \code{TRUE}, the respondent must select a response before
#'     moving on to subsequent pages of the questionnaire.
#' @param use.textArea (logical) if \code{FALSE}, displays a single-row edit line;
#'     if \code{TRUE}, displays a larger text area.
#' @param width (character) the width of the input, e.g. \code{'400px'} or \code{'100\%'}.
#' @param height (character) the height of the input, e.g. \code{'400px'} or \code{'100\%'}.
#'     If \code{use.textArea == FALSE}, this argument is ignored.
#' @param rows (character) the height of the input in text rows.
#'     If \code{use.textArea == FALSE}, this argument is ignored.
#'     If \code{height} is set, this argument is ignored.
#' @param placeholder (character) the text that will be displayed
#'     in the edit line when no text is entered yet.
#' @param regex (character) a regular expression that can be used to validate the entered value.
#' @param regexHint (character) a human-readable description of the regular expression
#'     to be displayed when the entered value doesn't match the \code{regex}.
#'     If \code{regex} is not set, this argument is ignored.
#'
#' @family question definitions
#' @seealso
#'     \code{\link[shiny]{textAreaInput}},
#'     \code{\link[shiny]{textInput}}.
#' @export
question.text <- function(id, label, required = TRUE, use.textArea = FALSE, width = NULL, height = NULL, rows = NULL,
                          placeholder = NULL, regex = NULL, regexHint = NULL) {
    force(names(as.list(environment())))

    if (!use.textArea) {
        if (!is.null(height)) {
            warning("height ignored - use.textArea is FALSE.")
        }
        if (!is.null(rows)) {
            warning("rows ignored - use.textArea is FALSE.")
        }
    } else {
        if (!is.null(height) && !is.null(rows)) {
            warning("rows ignored - height takes precedence.")
        }
    }

    if (!is.null(regexHint) && is.null(regex)) {
        warning("regexHint ignored - regex not defined.")
    }

    questionInputId <- makeQuestionInputId(id)

    ui <- function() {
        domain <- shiny::getDefaultReactiveDomain()
        input <- domain$input

        value <- shiny::isolate(input[[questionInputId]])

        if (use.textArea) {
            shiny::textAreaInput(
                height = height,
                inputId = questionInputId,
                label = label,
                placeholder = placeholder,
                rows = rows,
                value = value,
                width = width
            )
        } else {
            shiny::textInput(
                inputId = questionInputId,
                label = label,
                placeholder = placeholder,
                value = value,
                width = width
            )
        }
    }

    question <- buildQuestion(id = id, ui = ui)

    question$validate <- function() {
        result <- .validateIsAnswered(question, required)

        if ((result == .validResult) && !is.null(regex)) {
            domain <- shiny::getDefaultReactiveDomain()
            input <- domain$input

            value <- input[[questionInputId]]

            if (.isAnswered(value) && !grepl(regex, value)) {
                if (is.null(regexHint)) {
                    regexHint <- regex
                }

                result <- sprintf("Value does not match the given pattern (%s).", regexHint)
            }
        }

        result
    }

    question
}
