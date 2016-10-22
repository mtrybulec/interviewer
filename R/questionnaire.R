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

    isolate({
        itemTypes <- lapply(context$items, function(item) item$type)
        pageBreakIndexes <- which(itemTypes == .pageBreak)
    })

    navigate <- function(delta) {
        if (context$itemIndex <= 0) {
            context$itemIndex <- 1
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

            while (currentIndex <= length(context$items)) {
                item <- context$items[[currentIndex]]

                if ((length(class(item)) == 1) && (class(item) == "list") && (!is.null(item$type)) && (item$type == .pageBreak)) {
                    break;
                } else {
                    currentIndex <- currentIndex + 1
                }
            }

            context$page <- context$items[context$itemIndex:(currentIndex - 1)]
            shinyjs::runjs("window.scrollTo(0, 0);")
        }
    }

    shiny::observeEvent(input[[initButtonId]], {
        navigate(1)
        context$started <- TRUE
    })

    shiny::observeEvent(input[[backButtonId]], {
        navigate(-1)
    })

    shiny::observeEvent(input[[nextButtonId]], {
        validationFailed <- NULL
        validationResults <- context$validationResults

        for (question in context$page) {
            validationResult <- .validateResult(context, question)

            if ((validationResult != .validResult) && is.null(validationFailed)) {
                validationFailed <- question$id
            }

            validationResults[[question$id]] <- validationResult
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
                    lapply(context$page, function(question) {
                        questionInputId <- makeQuestionInputId(question$id)
                        questionStatusId <- .questionStatusId(questionInputId)

                        output[[questionStatusId]] <- shiny::renderUI({
                            validationResult <- context$validationResults[[question$id]]

                            if (!is.null(validationResult) && (validationResult != .validResult)) {
                                shiny::div(class = "interviewer-question-status", shiny::HTML(validationResult))
                            }
                        })

                        if ((length(class(question$ui)) == 1) && (class(question$ui) == "function")) {
                            questionUI <- question$ui(context)
                        } else {
                            questionUI <- question$ui
                        }

                        list(
                            questionUI,
                            shiny::uiOutput(outputId = questionStatusId)
                        )
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
