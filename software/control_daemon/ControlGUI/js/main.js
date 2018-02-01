// Default address
var ServerIP = "127.0.0.1";
var ISOOptions = ["100", "200", "400", "800"];
var SelectedISOOptionsindex = 0;
var ShutterOptions = ["1/10", "1/13", "1/15", "1/20", "1/25", "1/30", "1/40", "1/50", "1/100", "1/200", "1/400"];
var SelectedShutterOptionsindex = 0;
var ShutterSetAndClose = true;
var WBOptions = ["3200K", "4000K", "5600K"];
var SelectedWBOptionsindex = 0;
var Pages = ["home-page", "menu-page", "shutter-page", "iso-page"];

// Initial values
var settings = {
    HDR: 9
}

// Bindings
var manifest = {
    ui: {
        "#hdrValue": { bind: "HDR" }
    }
};

function startUp() {
    // Init Values
    $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
    $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
    $('#ShutterSetAndCloseValue').text(BoolToReadable(ShutterSetAndClose));

    // Just a test for data binding
    // On click it changes HDR value from 9 to 1
    $('#fpsValue').click(function () {
        $("#home-page").my("data", {HDR : 1});
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
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/50");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
    });
    $("#ShutterPresetBtn1_100").click(function () {
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/100");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
    });
    $("#ShutterPresetBtn1_200").click(function () {
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/200");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
    });
    $("#ShutterPresetBtn1_400").click(function () {
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/400");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        } else {
            $("#ShutterPresetBtn1_400").css("menuButton-currentvalue");
        }
    });
    $("#ShutterListBtn1_50").click(function () {
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/50");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
    });
    $("#ShutterListBtn1_25").click(function () {
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/25");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        }
    });
    $("#ShutterListBtn1_30").click(function () {
        SelectedShutterOptionsindex = GetIndexfromValue(ShutterOptions, "1/30");
        $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
        if (ShutterSetAndClose) {
            SwitchMenuPage("home-page");
        } else {
            $("#ShutterListBtn1_30").addClass("menuButton-currentvalue");
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
    $("#home-page").my(manifest, settings);

    startUp();
});