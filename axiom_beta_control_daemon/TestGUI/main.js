function startUp() {
    $('#demo').text("Test123");
    $("#slider").slider();
}

function decrementISO() {
    $.ajax({
        url: "http://rest-service.guides.spring.io/greeting"
    }).then(function (data) {
        //$('.greeting-id').append(data.id);
        //$('.greeting-content').append(data.content);
        console.log(data.content);
    });

}

function incrementISO() {
    var JSONObject = {
        "uname": "testUname",
        "password": "testPassword"
    };
    //var jsonData = JSON.parse(JSONObject);

    $.ajax({
        url: "https://jsonplaceholder.typicode.com/posts/1",
        type: "PUT",
        data: JSONObject,
        dataType: "json"
    }).then(function (data) {
        //$('.greeting-id').append(data.id);
        //$('.greeting-content').append(data.content);
        console.log(data.content);
    });
}

function sendSettings(settingName, value) {
    var setName = settingName;
    var JSONObject = {
        id : settingName,
        value: value
    };

    $.ajax({
        url: "http://127.0.0.1:7070/settings",
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

    if (value == 5) {
        valueText = "3/3";
    }

    $('#gainValue').text(valueText);
    sendSettings("gain", value);
});

function testFunc() {
    console.log($('#inc_gain').data("name"));
}

// Executes when page is loaded
$(document).ready(function () {
    startUp();
});