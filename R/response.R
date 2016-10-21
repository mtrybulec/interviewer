.checkResponses <- function(id, label) {
    if (length(unique(id)) != length(id)) {
        stop("Non-unique response identifiers.")
    }
    if (length(unique(label)) != length(label)) {
        stop("Non-unique response labels.")
    }
    if (length(id) != length(label)) {
        stop("Different identifier and label counts.")
    }
}

#' Build a definition of a response list.
#'
#' \code{buildResponses} returns response definitions given
#'     response identifiers and labels.
#'
#' @param id (character) the list of unique response identifiers.
#' @param label (character) the list of unique response labels.
#'
#' @family response buidling functions
#' @seealso
#'     \code{\link{randomizeResponses}}.
#' @export
buildResponses <- function(id, label) {
    .checkResponses(id, label)
    data.frame(id = id, label = label)
}

#' Merge two or more response lists.
#'
#' \code{mergeResponses} returns a single response list
#'     as a merge of individual response lists.
#'
#' @param ... (response lists) the list of response lists
#'     (e.g. as returned by \code{\link{buildResponses}}).
#'
#'     Response identifiers and labels must still be unique
#'     after the merge operation.
#'
#' @family response buidling functions
#' @seealso
#'     \code{\link{randomizeResponses}}.
#' @export
mergeResponses <- function(...) {
    mergedResponses <- do.call("rbind", list(...))
    .checkResponses(mergedResponses$id, mergedResponses$label)
    mergedResponses
}

#' Randomize the order of responses in a response list.
#'
#' \code{randomizeResponses} returns the same response list
#'     but randomly ordered.
#'
#' @param responses (response list) the list of responses
#'     (e.g. as returned by \code{\link{buildResponses}}).
#'
#' @family response handling functions
#' @seealso
#'     \code{\link{buildResponses}}.
#' @export
randomizeResponses <- function(responses) {
    rand <- sample(nrow(responses))
    responses[rand, ]
}

#' Mask the response list using responses given to another question.
#'
#' \code{maskResponses} drops or keeps those responses from the response list
#'     that were mentioned in an earlier question.
#'
#' @param responses (response list) the list of responses
#'     (e.g. as returned by \code{\link{buildResponses}}).
#' @param questionId (character) the identifier of the question
#'     that has the reference list of responses.
#' @param operation (character) if set to \code{'keep'}, only those responses
#'     in both response lists will be returned; if set to \code{'drop'},
#'     responses given in the reference question will be dropped from
#'     the given response list.
#'
#' @family response handling functions
#' @seealso
#'     \code{\link{buildResponses}}.
#' @export
maskResponses <- function(responses, questionId, operation = "keep") {
    responseIds <- getResponseIds(questionId)

    if (operation == "keep") {
        filter <- responses$id %in% responseIds
    } else if (operation == "drop") {
        filter <- !(responses$id %in% responseIds)
    } else {
        stop("Invalid value of operation; possible values: 'keep', 'drop'.")
    }

    responses[which(filter), ]
}

#' Get the identifiers of responses given by the respondent to another question.
#'
#' \code{getResponseIds} returns the identifiers to responses
#'     mentioned by the respondent in an earlier question.
#'     Can be \code{NULL} if no response was given.
#'     In case of text questions, returns the text verbatim.
#'
#' @param questionId (character) the identifier of the question.
#' @export
getResponseIds <- function(questionId) {
    domain <- shiny::getDefaultReactiveDomain()
    input <- domain$input

    input[[makeQuestionInputId(questionId)]]
}
