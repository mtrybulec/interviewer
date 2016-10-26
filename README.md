# interviewer

`interviewer` - questionnaires for computer-aided interviewing using R and Shiny.

Features:
* R *is* the questionnaire scripting language.
* The whole questionnaire is a single Shiny output, so do whatever you want with the rest of the page.
* Fully dynamic questionnaire logic: filters, loops, etc.
* All coded in R, so you can use any valid R instruction (`if`/`else`, `switch`, `for`/`while`/`repeat` loops, etc.).
* Use R variables, functions, objects, packages... anything.
* The questionnaire can be split into pages, each page containing one or more questions.
* Predefined question building functions:
  * single-choice questions using radio-buttons or combo-boxes,
  * multi-choice questions using check-boxes or combo-boxes (selectize),
  * mixed single- and multi-choice questions (e.g. "none of the above"),
  * vertical and horizontal/inline layouts of radio-buttons and check-boxes,
  * numeric questions using number edit lines or sliders,
  * text questions using single-line text inputs or multi-line text areas,
  * placeholders in combo-boxes and text inputs,
  * required/optional questions with default validation,
  * optional regex validation of text entries.
* Build custom questions with any valid Shiny output.
* Add custom validation functions.
* Add any valid Shiny output in-between questions.
* Dynamic response lists - modify response lists based on earlier responses.
* Helper functions to:
  * merge response lists,
  * randomize responses,
  * mask responses (keep, drop) using responses from an earlier question.
* Go back to already asked questions, go forward to the last question displayed (even through filters, loops, etc.).
* Data returned via a callback as a standard R data.frame.

`mixedOptionsInput` - a control that mixes radio-buttons and check-boxes -
can be used in any Shiny application as a normal input element.

See the [quick-start](https://github.com/mtrybulec/interviewer/blob/master/QUICK-START.md) guide for details.
