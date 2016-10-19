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
#' \code{buildResponses} retuns response definitions given
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
#' \code{mergeResponses} retuns a single response list
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
#' \code{randomizeResponses} retuns the same response list
#'     but randomly ordered.
#'
#' @param responses (response list) the list of responses
#'     (e.g. as returned by \code{\link{buildResponses}}).
#'
#' @seealso
#'     \code{\link{buildResponses}},
#'     \code{\link{mergeResponses}}.
#' @export
randomizeResponses <- function(responses) {
    rand <- sample(nrow(responses))
    responses[rand, ]
}
