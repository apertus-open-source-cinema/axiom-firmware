// Default address
var ServerIP = "127.0.0.1";

// ISO Page
var ISOOptions = ["200", "400", "800"];
var ISOPagesButtons = ["ISOBtn200", "ISOBtn400", "ISOBtn800"];

// Shutter Page
var ShutterOptions = ["custom", "1/10", "1/13", "1/15", "1/20", "1/25", "1/30", "1/40", "1/50", "1/60", "1/80",
    "1/100", "1/125", "1/160", "1/200", "1/250", "1/320", "1/400"];
var ShutterSetAndClose = true;
var ShutterPagesButtons = ["ShutterPresetBtn1_50", "ShutterPresetBtn1_100", "ShutterPresetBtn1_200"];


var WBOptions = ["3200K", "4000K", "5600K"];
var SelectedWBOptionsindex = 0;

// Menu Navigation
var Pages = ["home-page", "menu-page", "shutter-page", "iso-page", "shutter-preferences-page"];

// Initial values
var Settings = {
    SelectedShutterOptionsIndex: 4,
    SelectedISOOptionsindex: 0,
    HDR: "todo"
}

// Bindings
var manifest = {
    ui: {
        "#shutterValue": {
            bind: function () {
                return ShutterOptions[Settings.SelectedShutterOptionsIndex];
            }
        },
        "#isoValue": {
            bind: function () {
                return ISOOptions[Settings.SelectedISOOptionsindex];
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

        //Go fullscreen on mobile
        document.documentElement.webkitRequestFullScreen();
    });

    $("#MenuBtnClose").click(function () {
        SwitchMenuPage("home-page");
    });

    $("#ShutterBtn").click(function () {
        SwitchMenuPage("shutter-page");
    });

    $("#ISOBtn").click(function () {
        SwitchMenuPage("iso-page");
    });

    //Shutter Page
    $("#ShutterMenuBtnClose").click(function () {
        SwitchMenuPage("home-page");
    });

    $("#ShutterPresetBtn1_50").click(function () {
        $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, "1/50") });

        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
        HighlightSelectedValue(ShutterPagesButtons, this.id);
    });

    $("#ShutterPreset1Btn").click(function () {
        $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, "1/100") });

        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
        HighlightSelectedValue(ShutterPagesButtons, this.id);
    });

    $("#ShutterPresetBtn1_200").click(function () {
        $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, "1/200") });

        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
        HighlightSelectedValue(ShutterPagesButtons, this.id);
    });

    $("#ShutterIncEV").click(function () {
        if (Settings.SelectedShutterOptionsIndex > 1) {
            $("#home-page").my("data", { SelectedShutterOptionsIndex: Settings.SelectedShutterOptionsIndex - 1 });


            if (ShutterSetAndClose) {
                SwitchMenuPage("home-page");
            }
            HighlightSelectedValue(ShutterPagesButtons, "ShutterListBtn" + ShutterOptions[Settings.SelectedShutterOptionsIndex]
                .replace("/", "-"));

            scrollToElement("ShutterListBtn" + ShutterOptions[Settings.SelectedShutterOptionsIndex].replace("/", "-"), "ShutterBtnList");
        }
    });

    $("#ShutterDecEV").click(function () {
        if (Settings.SelectedShutterOptionsIndex < ShutterOptions.length - 1) {
            $("#home-page").my("data", { SelectedShutterOptionsIndex: Settings.SelectedShutterOptionsIndex + 1 });

            if (ShutterSetAndClose) {
                SwitchMenuPage("home-page");
            }
            HighlightSelectedValue(ShutterPagesButtons, "ShutterListBtn" + ShutterOptions[Settings.SelectedShutterOptionsIndex]
                .replace("/", "-"));

            scrollToElement("ShutterListBtn" + ShutterOptions[Settings.SelectedShutterOptionsIndex].replace("/", "-"), "ShutterBtnList");
        }
    });

    $("#ShutterSetAndCloseBtn").click(function () {
        ShutterSetAndClose = !ShutterSetAndClose;
        $('#ShutterSetAndCloseValue').text(BoolToReadable(ShutterSetAndClose));
    });
    $("#SetPresetBtn").click(function () {
        SaveLocalStorage();
    });
    $("#ShutterPreferencesBtn").click(function () {
        SwitchMenuPage("shutter-preferences-page");
    });

    // Shutter Preferences Page
    $("#radiogroup").click(function () {
        SwitchMenuPage("shutter-preferences-page");
    });
    $("#ShutterPreferencesCloseBtn").click(function () {
        SwitchMenuPage("shutter-page");
    });


    // ISO Page
    $("#ISOMenuBtnClose").click(function () {
        SwitchMenuPage("home-page");
    });
    $("#ISOBtn200").click(function () {
        $("#home-page").my("data", { SelectedISOOptionsindex: GetIndexfromValue(ISOOptions, "200") });
        HighlightSelectedValue(ISOPagesButtons, this.id);
        SwitchMenuPage("home-page");
    });
    $("#ISOBtn400").click(function () {
        $("#home-page").my("data", { SelectedISOOptionsindex: GetIndexfromValue(ISOOptions, "400") });
        HighlightSelectedValue(ISOPagesButtons, this.id);
        SwitchMenuPage("home-page");
    });
    $("#ISOBtn800").click(function () {
        $("#home-page").my("data", { SelectedISOOptionsindex: GetIndexfromValue(ISOOptions, "800") });
        HighlightSelectedValue(ISOPagesButtons, this.id);
        SwitchMenuPage("home-page");
    });

    // Menu Page
    $("#Test2SwitchBtn").click(function () {
        var checkBox = $("#Test2Switch");
        checkBox.prop("checked", !checkBox.prop("checked"));
    });

    $("#Test1SwitchBtn").click(function () {
        var checkBox = $("#Test1Switch");
        checkBox.prop("checked", !checkBox.prop("checked"));
    });
}

function LoadLocalStorage() {
    var ShutterPreset1 = localStorage.ShutterPreset1;
    $("#ShutterPreset1Btn").children(".buttonCaption").children(".Value").text(ShutterPreset1);
    var ShutterPreset2 = localStorage.ShutterPreset2;
    var ShutterPreset3 = localStorage.ShutterPreset3;
}
function SaveLocalStorage() {
    localStorage.ShutterPreset1 = 1;
}
function scrollToElement(object, container) {
    var topPos = document.getElementById(object).offsetTop;
    document.getElementById(container).scrollTop = topPos - 100;
}

function BoolToReadable(variable) {
    if (variable == true) {
        return "ON";
    } else if (variable == false) {
        return "OFF";
    }
}
function HighlightSelectedValue(allbuttons, selectedbutton) {
    // remove highlight from all buttons
    allbuttons.forEach(function (element) {
        if (typeof $('#' + element).attr('class') !== 'undefined') {
            $('#' + element).removeClass("menuButton-currentvalue");
        }
    });

    // highlight the one button
    if (typeof $('#' + selectedbutton).attr('class') !== 'undefined') {
        $('#' + selectedbutton).addClass("menuButton-currentvalue");
    }
}
function FillShutterBtnList(btnarray) {
    // fill the list of buttons from array automatically

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
            $("#" + btnname).on("click", function () {
                $("#home-page").my("data", { SelectedShutterOptionsIndex: GetIndexfromValue(ShutterOptions, element) });

                if (ShutterSetAndClose) {
                    SwitchMenuPage("home-page");
                }
                HighlightSelectedValue(ShutterPagesButtons, this.id);
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
    LoadLocalStorage();
});