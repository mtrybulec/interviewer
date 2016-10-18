#' @export
questionnaire <- function(surveyId, userId, label, welcome, goodbye, onExit, ...) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input
    output <- domain$output
    
    buttonsID <- "buttons"
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
        questionOrder = NULL
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
        
        for (question in context$pages[[context$pageIndex]]$questions) {
            validationResult <- .validateResult(question)
    
            if (nchar(validationResult) > 0) {
                validationFailed <- question$id
                break;    
            }
        }
        
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
    
    output[[buttonsID]] <- shiny::renderUI({
        initButtonDiv <- shiny::actionButton(inputId = buttonInitID, label = "Start")
        if (context$started) {
            initButtonDiv <- shinyjs::hidden(initButtonDiv)
        }
        
        backButtonDiv <- shiny::actionButton(inputId = buttonBackID, label = "Back")
        if (!context$started || (context$pageIndex <= 1)) {
            backButtonDiv <- shinyjs::hidden(backButtonDiv)
        }
        
        if (context$pageIndex >= length(context$pages)) {
            nextButtonLabel <- "Done"
        } else {
            nextButtonLabel <- "Next"
        }
        nextButtonDiv <- shiny::actionButton(inputId = buttonNextID, label = nextButtonLabel)
        if (!context$started) {
            nextButtonDiv <- shinyjs::hidden(nextButtonDiv)
        }

        shiny::tags$div(id = "interviewer-buttons",
            initButtonDiv,
            backButtonDiv,
            nextButtonDiv
        )
    })
  
    shiny::renderUI({
        if (context$done) {
            pageContent <- shiny::tags$p(goodbye)
        } else {
            if (!context$started) {
                pageContent <- shiny::tags$p(welcome)
            } else {
                pageContent <- context$page$ui(context)
            }
            
            pageContent <- list(
                pageContent,
                shiny::tags$hr(),
                shiny::uiOutput(outputId = buttonsID)
            )
        }
        
        list(
            shiny::tags$h2(label),
            shiny::tags$hr(),
            pageContent
        )
    })
}
