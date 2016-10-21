#' @export
questionnaire <- function(surveyId, userId, label, welcome, goodbye, exit, ...) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    output <- domain$output

    pageContentId <- "pageContent"
    initButtonId <- paste0(.buttonPrefix, "Init")
    backButtonId <- paste0(.buttonPrefix, "Back")
    nextButtonId <- paste0(.buttonPrefix, "Next")

    context <- shiny::reactiveValues(
        data = NULL,
        started = FALSE,
        done = FALSE,
        page = NULL,
        pages = list(...),
        pageIndex = 0,
        visitedPageIndexes = NULL,
        history = list(),
        validationResults = list()
    )

    setPage <- function(pageIndex) {
        prevIndex <- context$pageIndex
        context$pageIndex <- pageIndex
        context$page <- context$pages[[context$pageIndex]]

        if (prevIndex < pageIndex) {
            context$history[[context$page$id]] <- context$page

            for (question in context$page$questions) {
                context$history[[makeQuestionInputId(question$id)]] <- question
            }
        } else {
            historyPages <- grepl(paste0("^", .pagePrefix), names(context$history))
            lastHistoryPage <- max(which(historyPages))
            context$history <- context$history[1:(lastHistoryPage - 1)]
        }

        shinyjs::runjs("window.scrollTo(0, 0);")
    }

    shiny::observeEvent(input[[initButtonId]], {
        setPage(1)
        context$started <- TRUE
    })

    shiny::observeEvent(input[[backButtonId]], {
        setPage(context$pageIndex - 1)
    })

    shiny::observeEvent(input[[nextButtonId]], {
        context$visitedPageIndexes <- unique(c(context$visitedPageIndexes, context$pageIndex))

        validationFailed <- NULL
        validationResults <- context$validationResults

        for (question in context$page$questions) {
            validationResult <- .validateResult(context, question)

            if ((validationResult != .validResult) && is.null(validationFailed)) {
                validationFailed <- question$id
            }

            validationResults[[question$id]] <- validationResult
        }

        context$validationResults <- validationResults

        if (is.null(validationFailed)) {
            if (context$pageIndex >= length(context$pages)) {
                context$data <- shiny::reactiveValuesToList(input)
                context$done <- TRUE
            } else {
                setPage(context$pageIndex + 1)
            }
        } else {
            shinyjs::runjs(sprintf("interviewerJumpTo('%s');", validationFailed))
        }
    })

    shiny::observeEvent(context$done, {
        if (context$done) {
            data <- context$data
            data <- lapply(data, function(item) paste(item, collapse = ","))
            data <- as.data.frame(data)

            names <- colnames(data)
            names <- sub(paste0("^", .questionPrefix), "", names)
            colnames(data) <- names

            historyQuestions <- context$history[which(grepl(paste0("^", .questionPrefix), names(context$history)))]
            historyQuestionIds <- unlist(lapply(historyQuestions, function(question) as.list(question$dataIds)))

            data <- data[, intersect(historyQuestionIds, names), drop = FALSE]

            exit(data)
        }
    })

    shiny::observeEvent(context$started, {
        shinyjs::toggle(initButtonId, condition = !context$started)
        shinyjs::toggle(backButtonId, condition = context$started)
        shinyjs::toggle(nextButtonId, condition = context$started)
    })

    shiny::observe({
        shinyjs::toggleState(backButtonId, condition = context$started && (context$pageIndex > 1) && !context$done)
        shinyjs::toggleState(nextButtonId, condition = context$started && !context$done)
    })

    output[[pageContentId]] <- shiny::renderUI({
        if (!context$started) {
            pageContent <- shiny::p(welcome)
        } else {
            pageContent <-
                shiny::div(
                    id = context$page$id,
                    class = "page",
                    lapply(context$page$questions, function(question) {
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
                uiOutput(outputId = pageContentId),
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
