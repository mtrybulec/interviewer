library(interviewer)
library(shiny)

function(input, output, session) {

    output$questionnaireOutput <-
        interviewer::questionnaire(
            surveyId = "interviewer-demo-text",
            userId = "demo",
            label = "Text DEMO",
            welcome = list(
                shiny::p("Welcome!"),
                shiny::HTML("<p>This demo shows how <strong>text</strong> questions can be defined in <strong>interviewer</strong>.</p>")
            ),
            goodbye = "Done!",

            interviewer::question.text(
                id = "TextStandard",
                label = "Text, standard"
            ),

            interviewer::question.text(
                id = "TextOptional",
                label = "Text, no response required (required set to FALSE)",
                required = FALSE
            ),

            interviewer::question.text(
                id = "TextRegex",
                label = "Text, with regex validation (regex set to '^\\d{3} \\d{3}-\\d{3}$' and regexHint set to 'ddd ddd-ddd')",
                regex = "^\\d{3} \\d{3}-\\d{3}$",
                regexHint = "ddd ddd-ddd"
            ),

            interviewer::question.text(
                id = "TextNarrow",
                label = "Text, narrow (width set to '200px')",
                width = "200px"
            ),

            interviewer::question.text(
                id = "TextPlaceholder",
                label = "Text, with placeholder (placeholder set to 'Enter text')",
                placeholder = "Enter text",
                required = FALSE
            ),

            interviewer::pageBreak(),

            interviewer::question.text(
                id = "TextAreaStandard",
                label = "TextArea, standard (use.textArea set to TRUE)",
                use.textArea = TRUE
            ),

            interviewer::question.text(
                id = "TextAreaLarge",
                label = "TextArea, high and wide (width set to '400px', rows set to 5)",
                width = "400px",
                rows = 5,
                use.textArea = TRUE
            ),

            interviewer::question.text(
                id = "TextAreaSmall",
                label = "TextArea, short and narrow (width set to '200px', height set to '34px'):",
                height = '34px',
                width = "200px",
                use.textArea = TRUE
            ),

            interviewer::question.text(
                id = "TextAreaPlaceholder",
                label = "TextArea, with placeholder (placeholder set to 'Enter text')",
                use.textArea = TRUE,
                placeholder = "Enter text",
                required = FALSE
            ),

            exit = function(data) {
                cat("Done:\n")
                print(data)
            }
        )

}
