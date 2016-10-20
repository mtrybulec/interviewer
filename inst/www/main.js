function interviewerJumpTo(id) {
    document.getElementById(id).scrollIntoView(true);
}

// Support for radio-button non-response.
// http://stackoverflow.com/questions/10876953/how-to-make-a-radio-button-unchecked-by-clicking-it
function interviewerUncheckRadio(radio) {
    if (radio.prop("checked")) {
        var radioGroupDiv = radio.closest(".shiny-input-radiogroup");

        radio.one("click", function() {
            radio.prop("checked", false);
        });

        Shiny.onInputChange(radioGroupDiv.prop("id"), null);
    }
}

// mixedOptionsInput

function interviewerUncheckSiblingCheckBoxes(radio) {
    if (!radio.prop("checked")) {
        var optionsDiv = radio.closest(".shiny-input-radiogroup");

        if (optionsDiv.hasClass("interviewer-mixedoptionsgroup")) {
            var checkBoxes = optionsDiv.find("input[type='checkbox']");

            if (checkBoxes.length) {
                checkBoxes.prop("checked", false);
            }
        }
    }
}

function interviewerUncheckSiblingRadios(checkBox) {
    if (!checkBox.prop("checked")) {
        var optionsDiv = checkBox.closest(".shiny-input-checkboxgroup");

        if (optionsDiv.hasClass("interviewer-mixedoptionsgroup")) {
            var radios = optionsDiv.find("input[type='radio']");

            if (radios.length) {
                radios.prop("checked", false);
            }
        }
    }
}

// mixedOptionsInput - end.

$(document).ready(function () {
    $("body").on("mouseup", "input[type='radio']", function() {
        var radio = $(this);
        interviewerUncheckRadio(radio);
        interviewerUncheckSiblingCheckBoxes(radio);
    });

    $("body").on("mouseup", "input[type='checkbox']", function() {
        var checkBox = $(this);
        interviewerUncheckSiblingRadios(checkBox);
    });

    $("body").on("mouseup", "label", function() {
        var label = $(this);
        var radio;
        var checkBox;

        if (label.attr("for")) {
            radio = $("#" + label.attr("for")).filter("input[type='radio']");
            checkBox = $("#" + label.attr("for")).filter("input[type='checkbox']");
        } else {
            radio = label.children("input[type='radio']");
            checkBox = label.children("input[type='checkbox']");
        }

        if (radio.length) {
            interviewerUncheckRadio(radio);
            interviewerUncheckSiblingCheckBoxes(radio);
        }

        if (checkBox.length) {
            interviewerUncheckSiblingRadios(checkBox);
        }
    });
});
