hoptopus.ajaxCheckboxes = function (buttonName, checkboxClass, callbackFunction){

    $("#" + buttonName).click (function() {
        hoptopus.showProgress("Working...");
        makeSelectedUserCall($(this).attr("data-url-path"), function (request) {
            callbackFunction(request);
            hoptopus.hideProgress();
        });
    });

    function getValues(){
        var values = $("." + checkboxClass + ":checked");
        var data = { 'values' : []};
        values.each(function() {data['values'].push($(this).val());});
        return data;
    }

    function makeSelectedUserCall(url,callback) {
        var data = getValues();

        if(data['values'].length > 0) {
            $.ajax({ type: 'POST', url: url, data: data, success: callback, dataType: 'json' });
        } else {
            alert("You must select at least one person to revoke!");
            hoptopus.hideProgress();
        }
    }
};