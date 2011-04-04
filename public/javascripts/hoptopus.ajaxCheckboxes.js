hoptopus.ajaxCheckboxes = function (buttonName, checkboxClass, shouldConfirm, callbackFunction){

    $("#" + buttonName).click (function() {
        var shouldContinue = shouldConfirm ? confirm("Are you sure?") : true;

        if(shouldContinue){
          hoptopus.showProgress("Working...");
          makeSelectedUserCall($(this).attr("data-url-path"), function (request) {
              callbackFunction(request);
              hoptopus.hideProgress();
          });
        }
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
            alert("Nothing was selected -- no actions performed");
            hoptopus.hideProgress();
        }
    }
};