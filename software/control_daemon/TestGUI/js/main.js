// Default address
var serverIP = "127.0.0.1";
var ISOOptions = ["100", "200", "400", "800"];
var selectedISOOptionsindex = 0;
var ShutterOptions = ["1/25", "1/30", "1/50", "1/100", "1/200"];
var selectedShutterOptionsindex = 0;
var WBOptions = ["3200K", "4000K", "5600K"];
var selectedWBOptionsindex = 0;

function startUp() {
    $('#demo').text("Test123");
    $("#slider").slider();
    $('#IP').text(serverIP);
    $('#serverIP').val(serverIP);

    $("#MenuBtn").mouseup(function () {
        $('#home-page').css( "display", "none" )
        $('#menu-page').css( "display", "inline" )
    });

    $("#MenuBtnClose").mouseup(function () {
        $('#home-page').css( "display", "inline" )
        $('#menu-page').css( "display", "none" )
    });
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