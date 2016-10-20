function interviewerJumpTo(id) {
    document.getElementById(id).scrollIntoView(true);
}

// Support for radio-button non-response.
// http://stackoverflow.com/questions/10876953/how-to-make-a-radio-button-unchecked-by-clicking-it
function interviewerUncheckRadio(radio) {
    if (radio.prop("checked")) {
        var inputDiv = radio.closest(".shiny-input-radiogroup, .interviewer-mixedoptionsgroup");

        radio.one("click", function() {
            radio.prop("checked", false);
        });

        if (inputDiv) {
            Shiny.onInputChange(inputDiv.prop("id"), null);
        }
    }
}

// mixedOptionsInput checked handling.

function interviewerUncheckSiblingCheckBoxes(radio) {
    if (!radio.prop("checked")) {
        var inputDiv = radio.closest(".interviewer-mixedoptionsgroup");

        if (inputDiv) {
            var checkBoxes = inputDiv.find("input[type='checkbox']");

            if (checkBoxes.length) {
                checkBoxes.prop("checked", false);
            }
        }
    }
}

function interviewerUncheckSiblingRadios(checkBox) {
    if (!checkBox.prop("checked")) {
        var inputDiv = checkBox.closest(".interviewer-mixedoptionsgroup");

        if (inputDiv) {
            var radios = inputDiv.find("input[type='radio']");

            if (radios.length) {
                radios.prop("checked", false);
            }
        }
    }
}

// mixedOptionsInput checked handling - end.

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

// Based on radio-button/check-box code in Shiny:

var mixedOptionsInputBinding = new Shiny.InputBinding();

$.extend(mixedOptionsInputBinding, {
    find: function(scope) {
        return $(scope).find(".interviewer-mixedoptionsgroup");
    },

    getValue: function(el) {
        var values
        var radios = $("input:radio[name='" + Shiny.$escape(el.id) + "']:checked");

        if (radios.length) {
            values = radios.val();
        } else {
            var checkBoxes = $("input:checkbox[name='" + Shiny.$escape(el.id) + "']:checked");
            values = new Array(checkBoxes.length);

            for (var i = 0; i < checkBoxes.length; i ++) {
                values[i] = checkBoxes[i].value;
            }
        }

        return values;
    },

    setValue: function(el, value) {
        // Clear selections:
        $("input:radio[name='" + Shiny.$escape(el.id) + "']").prop("checked", false);
        $("input:checkbox[name='" + Shiny.$escape(el.id) + "']").prop("checked", false);

        // Set radio-button:
        $("input:radio[name='" + $escape(el.id) + "'][value='" + $escape(value) + "']").prop("checked", true);

        // Set check-boxes:
        if (value instanceof Array) {
            for (var i = 0; i < value.length; i++) {
                $("input:checkbox[name='" + Shiny.$escape(el.id) + "'][value='" + Shiny.$escape(value[i]) + "']").prop("checked", true);
            }
        } else {
            $("input:checkbox[name='" + Shiny.$escape(el.id) + "'][value='" + Shiny.$escape(value) + "']").prop("checked", true);
        }
    },

    subscribe: function(el, callback) {
        $(el).on("change.mixedOptionsInputBinding", function(event) {
            callback();
        });
    },

    unsubscribe: function(el) {
        $(el).off(".mixedOptionsInputBinding");
    }
});

Shiny.inputBindings.register(mixedOptionsInputBinding, "interviewer.mixedOptionsInput");
