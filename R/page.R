#' @export
page <- function(id, ...) {
    list(
        id = .pageId(id),
        questions = list(...)
    )
}
