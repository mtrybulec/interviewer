.packageName <- "interviewer"

.buttonPrefix = "button"
.pagePrefix = "page"
.questionPrefix <- "question"
.questionStatusPrefix <- "questionStatus"

.pageId <- function(id) {
    paste0(.pagePrefix, id)
}

.questionId <- function(id) {
    paste0(.questionPrefix, id)
}
.questionStatusId <- function(id) {
    paste0(.questionStatusPrefix, id)
}