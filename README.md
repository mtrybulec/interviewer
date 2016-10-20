# interviewer

`interviewer` - questionnaires for computer-aided interviewing using R and Shiny.

Features:
* R *is* the scripting language.
* The whole questionnaire is a single Shiny output, so do whatever you want with the rest of the page.
* The whole questionnaire is split into pages, each page contains one or more questions.
* Single-choice questions using radio-buttons or combo-boxes.
* Multi-choice questions using check-boxes or combo-boxes (selectize).
* Vertical or horizontal (inline) layout of radio-buttons and check-boxes.
* Numeric questions using number edit lines or sliders.
* Text questions using single-line text inputs or multi-line text areas.
* Placeholders in combo-boxes and text inputs.
* Required/optional questions.
* Optional regex validation of text entries.
* Add any valid Shiny output in-between questions.
* Build custom questions, including validation functions, with any valid Shiny output.
* Dynamic response lists - modify response lists based on ealier responses.
* Helper functions to:
  * merge response lists,
  * randomize responses,
  * mask responses (keep, drop) using responses from an earlier question.
* Go back to already asked questions, go forward to the last question displayed.
* Data returned via a callback as a standard R data.frame.
