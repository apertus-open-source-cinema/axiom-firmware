// Default address
var ServerIP = "127.0.0.1";

var ISOOptions = ["100", "200", "400", "800"];
var SelectedISOOptionsindex = 0;

// Shutter Page
var ShutterOptions = ["custom", "1/10", "1/13", "1/15", "1/20", "1/25", "1/30", "1/40", "1/50", "1/60", "1/80",
    "1/100", "1/125", "1/160", "1/200", "1/250", "1/320", "1/400"];
var ShutterSetAndClose = true;
var ShutterPagesButtons = ["ShutterPresetBtn1_50", "ShutterPresetBtn1_100", "ShutterPresetBtn1_200"];


var WBOptions = ["3200K", "4000K", "5600K"];
var SelectedWBOptionsindex = 0;

// Menu Navigation
var Pages = ["home-page", "menu-page", "shutter-page", "iso-page"];

// Initial values
var Settings = {
    SelectedShutterOptionsIndex: 4,
    HDR: 9
}

// Bindings
var manifest = {
    ui: {
        "#hdrValue": { bind: "HDR" },
        "#shutterValue": {
            bind: function () {
                return ShutterOptions[Settings.SelectedShutterOptionsIndex];
            }
        }
    }
};

function startUp() {
    // Init Values
    $("#ShutterSetAndCloseValue").text(BoolToReadable(ShutterSetAndClose));
    FillShutterBtnList(ShutterOptions);

    // Just a test for data binding
    // On click it changes HDR value from 9 to 1
    $("#fpsValue").click(function () {
        $("#home-page").my("data", { HDR: 1 });
    });

    //Buttons
    $("#MenuBtn").click(function () {
        SwitchMenuPage("menu-page");
    });

    $("#MenuBtnClose").click(function () {
        SwitchMenuPage("home-page");
    });

    $("#ShutterBtn").click(function () {
        SwitchMenuPage("shutter-page");
    });

    //Shutter Page
    $("#ShutterMenuBtnClose").click(function () {
        SwitchMenuPage("home-page");
    });

    $("#ShutterPresetBtn1_50").click(function () {
        $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, "1/50") });

        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        } else {
            HighlightSelectedValue(ShutterPagesButtons, "ShutterPresetBtn1_50");
        }
    });

    $("#ShutterPresetBtn1_100").click(function () {
        $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, "1/100") });

        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        } else {
            HighlightSelectedValue(ShutterPagesButtons, "ShutterPresetBtn1_100");
        }
    });

    $("#ShutterPresetBtn1_200").click(function () {
        $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, "1/200") });

        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        } else {
            HighlightSelectedValue(ShutterPagesButtons, "ShutterPresetBtn1_200");
        }
    });

    $("#ShutterSetAndCloseBtn").click(function () {
        ShutterSetAndClose = !ShutterSetAndClose;
        $('#ShutterSetAndCloseValue').text(BoolToReadable(ShutterSetAndClose));
    });

}

function BoolToReadable(variable) {
    if (variable == true) {
        return "ON";
    } else if (variable == false) {
        return "OFF";
    }
}
function HighlightSelectedValue(allbuttons, selectedbutton) {
    allbuttons.forEach(function (element) {
        if (typeof $('#' + element).attr('class') !== 'undefined') {
            if ($('#' + element).attr('class').includes("row-option")) {
                $('#' + element).removeClass("menuButton-currentvalue");
            } else {
                $('#' + element).children(".Value").removeClass("menuButton-currentvalue");
            }
        }
    });
    if (typeof $('#' + selectedbutton).attr('class') !== 'undefined') {
        if ($('#' + selectedbutton).attr('class').includes("row-option")) {
            $('#' + selectedbutton).addClass("menuButton-currentvalue");
        } else {
            $('#' + selectedbutton).children(".Value").addClass("menuButton-currentvalue");
        }
    }
}
function FillShutterBtnList(btnarray) {
    var fillreturn = "";
    btnarray.forEach(function (element) {
        if (element != "custom") {
            fillreturn += '<div class="row-option menuButton" id="ShutterListBtn' + element.replace("/", "-") + '">';
            fillreturn += '<div class="row-option-item">' + element + '</div>';
            fillreturn += '</div >';
            ShutterPagesButtons.push("ShutterListBtn" + element.replace("/", "-"));
        }
    });

    $('#ShutterBtnList').append(fillreturn);

    btnarray.forEach(function (element) {
        if (element != "custom") {
            btnname = "ShutterListBtn" + element.replace("/", "-");
            $("#" + btnname).on( "click", function() {
                $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, element) });

                if (ShutterSetAndClose) {
                    SwitchMenuPage("home-page");
                } else {
                    HighlightSelectedValue(ShutterPagesButtons, (btnname));
                }
            });
        }
    });
}

function SwitchMenuPage(page) {
    Pages.forEach(function (element) {
        $('#' + element).css("display", "none");
    });
    $('#' + page).css("display", "inline");
}

function GetIndexfromValue(targetarray, arrayvalue) {
    return targetarray.findIndex(function (search) { return (search == arrayvalue); })
}

function sendSettings(settingName, value) {
    var setName = settingName;
    var JSONObject = {
        id: settingName,
        value: value
    };

    $.ajax({
        url: "http://" + serverIP + "/api/settings",
        type: "PUT",
        data: JSON.stringify(JSONObject),
        crossDomain: true,
        dataType: "json",
        success: function (responseData, textStatus, jqXHR) {
            console.log(responseData);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            if (xhr.status == 404) {
                console.log(thrownError);
            }
        }
    });
}

// input: on release, change: immediately, e.g. when dragging
// $(document).on("change", '#gain', function () {
//     var value = $('#gain').val();
//     var valueText = value;

//     if (value == 4) {
//         valueText = "3/3";
//     }

//     $('#gainValue').text(valueText);
//     sendSettings("gain", value);
// });

// $(document).on("change, input", '#serverIP', function () {
//     serverIP = $('#serverIP').val();
//     $('#IP').text(serverIP);
// });


function testFunc() {
    console.log($('#inc_gain').data("name"));
}

// Executes when page is loaded
$(document).ready(function () {
    $("#home-page").my(manifest, Settings);

    startUp();
});