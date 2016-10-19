#' @export
questionnaire <- function(surveyId, userId, label, welcome, goodbye, onExit, ...) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    output <- domain$output
    session <- domain$session

    pageContentId <- "pageContent"    
    buttonInitID <- paste0(.buttonPrefix, "Init")
    buttonBackID <- paste0(.buttonPrefix, "Back")
    buttonNextID <- paste0(.buttonPrefix, "Next")

    context <- shiny::reactiveValues(
        data = NULL,
        started = FALSE,
        done = FALSE,
        page = NULL,
        pages = list(...),
        pageIndex = 1,
        visitedPageIndexes = NULL,
        questionOrder = NULL,
        validationResults = list()
    )

    shiny::isolate({
        context$page <- context$pages[[context$pageIndex]]
    })
    
    shiny::observeEvent(input[[buttonInitID]], {
        context$started <- TRUE
    })
  
    shiny::observeEvent(input[[buttonBackID]], {
        context$pageIndex <- context$pageIndex - 1
        context$page <- context$pages[[context$pageIndex]]
    })

    shiny::observeEvent(input[[buttonNextID]], {
        context$visitedPageIndexes <- unique(c(context$visitedPageIndexes, context$pageIndex))
        
        validationFailed <- NULL
        validationResults <- context$validationResults
        
        for (question in context$pages[[context$pageIndex]]$questions) {
            if (.isQuestion(question)) {
                validationResult <- .validateResult(context, question)
                
                if ((validationResult != .validResult) && is.null(validationFailed)) {
                    validationFailed <- question$id
                }
                
                validationResults[[question$id]] <- validationResult
            }
        }
        
        context$validationResults <- validationResults
        
        if (is.null(validationFailed)) {
            if (context$pageIndex >= length(context$pages)) {
                context$data <- shiny::reactiveValuesToList(input)
                context$done <- TRUE
            } else {
                context$pageIndex <- context$pageIndex + 1
                context$page <- context$pages[[context$pageIndex]]
                shinyjs::runjs("window.scrollTo(0, 0);")
            }
        } else {
            shinyjs::runjs(sprintf("interviewerJumpTo('%s');", validationFailed))
        }
    })

    shiny::observe({
        if (context$done) {
            data <- context$data
            data <- lapply(data, function(item) paste(item, collapse = ","))
            data <- as.data.frame(data)
            
            names <- colnames(data)
            names <- sub(paste0("^", .questionPrefix), "", names)
            colnames(data) <- names

            data <- data[, intersect(context$questionOrder, names)]
            
            onExit(data)
        }
    })
    
    shiny::observe({
        shinyjs::toggle(buttonInitID, condition = !context$started)
        shinyjs::toggle(buttonBackID, condition = context$started)
        shinyjs::toggle(buttonNextID, condition = context$started)
        
        shinyjs::toggleState(buttonBackID, condition = context$started && (context$pageIndex > 1) && !context$done)
        shinyjs::toggleState(buttonNextID, condition = context$started && !context$done)
        
        if (context$pageIndex >= length(context$pages)) {
            nextButtonLabel <- "Done"
        } else {
            nextButtonLabel <- "Next"
        }

        shiny::updateActionButton(session, buttonNextID, label = nextButtonLabel)
    })
    
    output[[pageContentId]] <- shiny::renderUI({
        if (!context$started) {
            pageContent <- shiny::p(welcome)
        } else {
            pageContent <- context$page$ui(context)
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
                shiny::actionButton(inputId = buttonInitID, label = "Start"),
                shinyjs::hidden(shiny::actionButton(inputId = buttonBackID, label = "Back")),
                shinyjs::hidden(shiny::actionButton(inputId = buttonNextID, label = ""))
            )
        }
        
        list(
            shiny::h2(label),
            shiny::hr(),
            screenContent
        )
    })
}
