.function <- "function"

#' Define an \code{interviewer} questionnaire.
#'
#' \code{questionnaire} is the central function via which the whole questionnaire,
#'     including its questions, responses, and flow logic, is defined.
#'
#' @param label (character) the name/label/text that will be displayed
#'     at the top of the UI area assigned to the questionnaire.
#' @param welcome (Shiny tag list) the Shiny output that will be displayed
#'     as the first page of the questionnaire - the welcome page.
#' @param goodbye (Shiny tag list) the Shiny output that will be displayed
#'     as the last page of the questionnaire, after the respondent
#'     replies to the last question.
#' @param exit (function(data.frame)) the callback function that will be called
#'     after the interview finishes; the data.frame will contain responses
#'     to all interview questions; column names will be named using
#'     question ids, and the single row will have the respondent's answers.
#' @param ... question definitions, non-question UI output,
#'     and functions defining the logic of the questionnaire.
#'
#' @details See \url{https://github.com/mtrybulec/interviewer/blob/master/doc/QUICK-START.md}
#'    for details on using \code{questionnaire} in Shiny apps.
#'
#' @seealso
#'     \code{\link{runExample}}.
#' @export
questionnaire <- function(label, welcome, goodbye, exit, ...) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    output <- domain$output

    pageOutputId <- "pageOutput"

    buttonPrefix = "button"
    initButtonId <- paste0(buttonPrefix, "Init")
    backButtonId <- paste0(buttonPrefix, "Back")
    nextButtonId <- paste0(buttonPrefix, "Next")

    context <- shiny::reactiveValues(
        started = FALSE,
        done = FALSE,
        items = list(...),
        itemIndex = 0, # points to the first item on a page
        page = NULL,
        validationResults = list()
    )

    isFunction <- function(item) {
        (length(class(item)) == 1) && (class(item) == "function")
    }

    isItemType <- function(item, types) {
        (length(class(item)) == 1) && (class(item) == "list") && (!is.null(item$type)) && (item$type %in% types)
    }

    # After applying functions (on Next or Back), need to recalculate where the current page breaks are
    # (to be able to show questions that are on the current screen).
    recalculatePageBreakIndexes <- function() {
        shiny::isolate({
            itemTypes <- lapply(context$items, function(item) {
                if (isFunction(item)) {
                    .function
                } else {
                    item$type
                }
            })

            which(itemTypes == .pageBreak)
        })
    }

    # Calculate initial indexes of page breaks:
    pageBreakIndexes <- recalculatePageBreakIndexes()

    getPrevPageBreakIndex <- function(currentIndex) {
        prevPageBreakIndexes <- pageBreakIndexes[which(pageBreakIndexes < currentIndex)]

        if (length(prevPageBreakIndexes) == 0) {
            result <- 0
        } else {
            result <- max(prevPageBreakIndexes)
        }

        result
    }

    getNextPageBreakIndex <- function(currentIndex) {
        nextPageBreakIndexes <- pageBreakIndexes[which(pageBreakIndexes > currentIndex)]

        if (length(nextPageBreakIndexes) == 0) {
            result <- length(context$items) + 1
        } else {
            result <- min(nextPageBreakIndexes)
        }

        result
    }

    # Expand any (collapsed / non-expanded) functions found on this page:
    expandFunctionsOnCurrentPage <- function() {
        currentIndex <- context$itemIndex
        functionFound <- FALSE

        while (currentIndex <= length(context$items)) {
            item <- context$items[[currentIndex]]

            if (isFunction(item)) {
                functionFound <- TRUE

                expandedItem <- item()

                if (isItemType(expandedItem, c(.nonQuestion, .pageBreak, .question))) {
                    expandedItem <- list(expandedItem)
                }

                functionItem <- list(
                    type = .function,
                    call = item,
                    resultCount = length(expandedItem)
                )

                newItems <- list()
                if (currentIndex > 1) {
                    newItems <- c(newItems, context$items[1:(currentIndex - 1)])
                }
                newItems <- c(newItems, list(functionItem))
                if (length(expandedItem) > 0) {
                    newItems <- c(newItems, expandedItem)
                }
                newItems <- c(newItems, context$items[(currentIndex + 1):length(context$items)])

                context$items <- newItems
            } else if (isItemType(item, .pageBreak)) {
                break;
            }

            currentIndex <- currentIndex + 1
        }

        if (functionFound) {
            pageBreakIndexes <<- recalculatePageBreakIndexes()
        }

        context$page <- context$items[context$itemIndex:(currentIndex - 1)]
        shinyjs::runjs("window.scrollTo(0, 0);")
    }

    # Collapse any (expanded) functions found on all pages after the current page:
    collapseFunctionsOnSubsequentPages <- function() {
        currentIndex <- getNextPageBreakIndex(context$itemIndex)
        functionFound <- FALSE

        if (currentIndex < length(context$items)) {
            for (nextIndex in length(context$items):(currentIndex + 1)) {
                item <- context$items[[nextIndex]]

                if (isItemType(item, .function)) {
                    functionFound <- TRUE
                    collapsedItem <- item$call

                    newItems <- c(context$items[1:(nextIndex - 1)], collapsedItem)

                    mergeIndex <- nextIndex + item$resultCount + 1
                    if (mergeIndex <= length(context$items)) {
                        newItems <- c(newItems, context$items[mergeIndex:length(context$items)])
                    }

                    context$items <- newItems
                }
            }
        }

        if (functionFound) {
            pageBreakIndexes <<- recalculatePageBreakIndexes()
        }
    }

    # Navigate to the next (delta == 1) or previous (delta == -1) page.
    navigate <- function(delta) {
        if (context$itemIndex <= 0) {
            context$itemIndex <- 1
            context$started <- TRUE
        } else {
            if (delta < 0) {
                context$itemIndex <- getPrevPageBreakIndex(context$itemIndex - 1) + 1
            } else {
                context$itemIndex <- getNextPageBreakIndex(context$itemIndex) + 1

                if (context$itemIndex > length(context$items)) {
                    context$done <- TRUE
                }
            }
        }

        if (!context$done) {
            expandFunctionsOnCurrentPage()
            collapseFunctionsOnSubsequentPages()
        }
    }

    shiny::observeEvent(input[[initButtonId]], {
        navigate(1)
    })

    shiny::observeEvent(input[[backButtonId]], {
        navigate(-1)
    })

    shiny::observeEvent(input[[nextButtonId]], {
        validationFailed <- NULL
        validationResults <- context$validationResults

        for (item in context$page) {
            if (item$type == .question) {
                validationResult <- .validateResult(item)

                if ((validationResult != .validResult) && is.null(validationFailed)) {
                    validationFailed <- item$id
                }

                validationResults[[item$id]] <- validationResult
            }
        }

        context$validationResults <- validationResults

        if (is.null(validationFailed)) {
            navigate(1)
        } else {
            shinyjs::runjs(sprintf("interviewerJumpTo('%s');", validationFailed))
        }
    })

    shiny::observeEvent(context$done, {
        if (context$done) {
            data <- shiny::reactiveValuesToList(input)
            data <- lapply(data, function(item) paste(item, collapse = ","))
            data <- as.data.frame(data)

            names <- colnames(data)
            names <- sub(paste0("^", .question), "", names)
            colnames(data) <- names

            questionIds <- unlist(lapply(context$items, function(item) as.list(item$dataIds)))

            data <- data[, intersect(questionIds, names), drop = FALSE]

            exit(data)
        }
    })

    shiny::observeEvent(context$started, {
        shinyjs::toggle(initButtonId, condition = !context$started)
        shinyjs::toggle(backButtonId, condition = context$started)
        shinyjs::toggle(nextButtonId, condition = context$started)
    })

    shiny::observe({
        shinyjs::toggleState(backButtonId, condition = context$started && (context$itemIndex > 1) && !context$done)
        shinyjs::toggleState(nextButtonId, condition = context$started && !context$done)
    })

    output[[pageOutputId]] <- shiny::renderUI({
        if (!context$started) {
            pageContent <- shiny::p(welcome)
        } else {
            pageContent <-
                shiny::div(
                    class = "page",
                    lapply(context$page, function(item) {
                        if (item$type %in% c(.question, .nonQuestion)) {
                            if (isFunction(item$ui)) {
                                itemUI <- item$ui()
                            } else {
                                itemUI <- item$ui
                            }

                            if (item$type == .question) {
                                questionInputId <- makeQuestionInputId(item$id)
                                questionStatusId <- .questionStatusId(questionInputId)

                                output[[questionStatusId]] <- shiny::renderUI({
                                    validationResult <- context$validationResults[[item$id]]

                                    if (!is.null(validationResult) && (validationResult != .validResult)) {
                                        shiny::div(class = "interviewer-question-status", shiny::HTML(validationResult))
                                    }
                                })

                                list(
                                    itemUI,
                                    shiny::uiOutput(outputId = questionStatusId)
                                )
                            } else {
                                itemUI
                            }
                        }
                    })
                )
        }

        pageContent
    })

    shiny::renderUI({
        if (context$done) {
            screenContent <- shiny::p(goodbye)
        } else {
            screenContent <- list(
                shiny::uiOutput(outputId = pageOutputId),
                shiny::hr(),
                shiny::actionButton(inputId = initButtonId, label = "Start"),
                shinyjs::hidden(shiny::actionButton(inputId = backButtonId, label = "Back")),
                shinyjs::hidden(shiny::actionButton(inputId = nextButtonId, label = "Next"))
            )
        }

        list(
            shiny::h2(label),
            shiny::hr(),
            screenContent
        )
    })
}
