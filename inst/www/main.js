function interviewerJumpTo(id) {
    document.getElementById(id).scrollIntoView(true);
}

// Support for radio-button non-response.
// http://stackoverflow.com/questions/10876953/how-to-make-a-radio-button-unchecked-by-clicking-it
function interviewerUncheckRadio(radio) {
    if (radio.prop("checked")) {
        var radioGroupDiv = radio.closest(".shiny-input-radiogroup");

        radio.one("click", function() { radio.prop("checked", false); } );
        Shiny.onInputChange(radioGroupDiv.prop("id"), null); // make sure that Shiny input value is reset after check -> uncheck
    }
}

$(document).ready(function () {
    $("body").on("mouseup", "input[type='radio']", function() {
        var radio = $(this);
        interviewerUncheckRadio(radio);
    })
    
    $("body").on("mouseup", "label", function() {
        var label = $(this);
        var radio;
        
        if (label.attr("for"))
            radio = $("#" + label.attr("for")).filter("input[type='radio']");
        else
            radio = label.children("input[type='radio']");
        
        if (radio.length)
            interviewerUncheckRadio(radio);
    })
});

