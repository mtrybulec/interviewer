.function <- "function"

#' @export
questionnaire <- function(surveyId, userId, label, welcome, goodbye, exit, ...) {
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
        isolate({
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

    pageBreakIndexes <- recalculatePageBreakIndexes()

    # Navigate to the next (delta == 1) or previous (delta == -1) page.
    navigate <- function(delta) {
        if (context$itemIndex <= 0) {
            context$itemIndex <- 1
            context$started <- TRUE
        } else {
            if (delta < 0) {
                prevPageBreakIndexes <- pageBreakIndexes[which(pageBreakIndexes < context$itemIndex - 1)]

                if (length(prevPageBreakIndexes) == 0) {
                    context$itemIndex <- 1
                } else {
                    context$itemIndex <- max(prevPageBreakIndexes) + 1
                }
            } else {
                nextPageBreakIndexes <- pageBreakIndexes[which(pageBreakIndexes > context$itemIndex)]

                if (length(nextPageBreakIndexes) == 0) {
                    context$done <- TRUE
                } else {
                    context$itemIndex <- min(nextPageBreakIndexes) + 1
                }
            }
        }

        if (!context$done) {
            currentIndex <- context$itemIndex
            functionFound <- FALSE

            # Handle current page - expand any functions found on this page:
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

            # Handle pages after the current page - collapse any functions found there:
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

            context$page <- context$items[context$itemIndex:(currentIndex - 1)]
            shinyjs::runjs("window.scrollTo(0, 0);")
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
                        if (item$type == .question) {
                            questionInputId <- makeQuestionInputId(item$id)
                            questionStatusId <- .questionStatusId(questionInputId)

                            output[[questionStatusId]] <- shiny::renderUI({
                                validationResult <- context$validationResults[[item$id]]

                                if (!is.null(validationResult) && (validationResult != .validResult)) {
                                    shiny::div(class = "interviewer-question-status", shiny::HTML(validationResult))
                                }
                            })

                            if ((length(class(item$ui)) == 1) && (class(item$ui) == "function")) {
                                questionUI <- item$ui()
                            } else {
                                questionUI <- item$ui
                            }

                            list(
                                questionUI,
                                shiny::uiOutput(outputId = questionStatusId)
                            )
                        } else if (item$type == .nonQuestion) {
                            if ((length(class(item$ui)) == 1) && (class(item$ui) == "function")) {
                                nonQuestionUI <- item$ui()
                            } else {
                                nonQuestionUI <- item$ui
                            }

                            nonQuestionUI
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
                uiOutput(outputId = pageOutputId),
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
