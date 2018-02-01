// Default address
var ServerIP = "127.0.0.1";
var ISOOptions = ["100", "200", "400", "800"];
var SelectedISOOptionsindex = 0;
var ShutterOptions = ["1/25", "1/30", "1/50", "1/100", "1/200"];
var SelectedShutterOptionsindex = 0;
var WBOptions = ["3200K", "4000K", "5600K"];
var SelectedWBOptionsindex = 0;
var Pages = ["home-page", "menu-page", "shutter-page"];

function startUp() {
    $('#shutterValue').text(ShutterOptions[SelectedShutterOptionsindex]);
    $('#isoValue').text(ISOOptions[SelectedISOOptionsindex]);

    $("#MenuBtn").mouseup(function () {
        SwitchMenuPage("menu-page");
    });

    $("#MenuBtnClose").mouseup(function () {
        SwitchMenuPage("home-page");
    });

    $("#ShutterMenuBtnClose").mouseup(function () {
        SwitchMenuPage("home-page");
    });

    $("#ShutterBtn").mouseup(function () {
        
        SwitchMenuPage("shutter-page");
    });
}

function SwitchMenuPage(page) {
    Pages.forEach(function (element) {
        $('#'+element).css("display", "none");
    });
    $('#'+page).css("display", "inline");
/*
    if (page == "home-page") {
        $('#home-page').css("display", "inline");
        $('#menu-page').css("display", "none");
        $('#shutter-page').css("display", "none")
    } else if (page == "menu-page") {
        $('#home-page').css("display", "none");
        $('#menu-page').css("display", "inline");
        $('#shutter-page').css("display", "none");
    } else if (page == "shutter-page") {
        $('#home-page').css("display", "none");
        $('#menu-page').css("display", "none");
        $('#shutter-page').css("display", "inline")
    }*/
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
$(document).on("change", '#gain', function () {
    var value = $('#gain').val();
    var valueText = value;

    if (value == 4) {
        valueText = "3/3";
    }

    $('#gainValue').text(valueText);
    sendSettings("gain", value);
});

$(document).on("change, input", '#serverIP', function () {
    serverIP = $('#serverIP').val();
    $('#IP').text(serverIP);
});


function testFunc() {
    console.log($('#inc_gain').data("name"));
}

// Executes when page is loaded
$(document).ready(function () {
    startUp();
});