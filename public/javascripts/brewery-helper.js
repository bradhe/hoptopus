function findBrew(brewId) {
	var currentBrewery = brews[$('select#brewery').val()];
	for(var i in currentBrewery) {
		var obj = currentBrewery[i];
		if(typeof(obj) != 'object') {
			continue;
		}
		
		if(obj.brew.id == brewId) {
			return obj.brew;
		}	
	}
}

$('select#brewery').live('change', function() {
	var selectBrews = $('select#beer_brew_id');
	var button = $('#add-beer');
	
	if(!selectBrews) {
		throw "Couldn't find brews list. Ass.";
	}
	
	if($(this).val() == '') {
		// TODO: Add more stuff here. Disable selectBrews, add first element, etc.
		selectBrews.empty();
		selectBrews.attr('disabled', true);
		button.attr('disabled', true);
		selectBrews.append($('<option/>').val('').text('Select a Brewery'));
		
		return;
	}
	
	var breweryBrews = brews[$(this).val()];
	if(!breweryBrews) {
		throw "No brews for this brewery.";
	}
	
	// Populate the other drop down
	selectBrews.empty();
	
	// If this brewery doesn't have any brews then...boned.
	if (breweryBrews.length < 1) {
		selectBrews.attr('disabled', true);
		button.attr('disabled', true);
		selectBrews.append($('<option/>').val('').text('No beers in the wiki for this brewery.'));
		
		return;
	}	
	else {
		selectBrews.removeAttr('disabled');
		
		// Set up this thing so the button gets disabled.
		selectBrews.change(function() {
			if($(this).val() != '') {
				button.removeAttr('disabled');
								
				// Get the current brew
				var brew = findBrew($(this).val());
				
				// Also populate the ABV and IBU fields if they exist.
				var abv = $('#beer_abv');
				if(abv && brew.abv) {
					// Find the beer for this thing.
					abv.val(brew.abv.toFixed(2));
				}
                
                var finishedAt = $('#beer_finish_aging_at');
                var startedAt = $('#beer_cellared_at');
                var finishYearBox =  $('#beer_finish_aging_year');
                var finishMonthBox =  $('#beer_finish_aging_month');

                // Now set up the suggested shit if it's there
                if(brew.suggested_aging_years) {
                    finishYearBox.val(brew.suggested_aging_years);
                }
                
                if(brew.suggested_aging_months) {
                    finishMonthBox.val(brew.suggested_aging_months);
                }
                
                // Recalc if nescessary
                if(brew.suggested_aging_months || brew.suggested_aging_years) {
                    recalculateFinishDateFromYearAndMonth(finishedAt, startedAt, finishMonthBox, finishYearBox);
                }
			}
			else {
				button.attr('disabled', true);
			}
		});
	}
	
	selectBrews.append($('<option/>').val('').text('Select a Beer'));
	
	for(var i in breweryBrews) {
		var brew = breweryBrews[i];
		
		if(typeof(brew) != 'object') {
			continue;
		}
		
		selectBrews.append($('<option/>').val(brew.brew.id).text(brew.brew.name));
	}
});

$('#beer_finish_aging_year').live('change', function() {
    var startedAt = $('#beer_cellared_at');
    var finishedAt = $('#beer_finish_aging_at');
    var finishMonthBox =  $('#beer_finish_aging_month');
    recalculateFinishDateFromYearAndMonth(finishedAt, startedAt, finishMonthBox, $(this));
});

$('#beer_finish_aging_month').live('change', function() {
    var startedAt = $('#beer_cellared_at');
    var finishedAt = $('#beer_finish_aging_at');
    var finishYearBox =  $('#beer_finish_aging_year');
    recalculateFinishDateFromYearAndMonth(finishedAt, startedAt, $(this), finishYearBox);
});

$('#beer_cellared_at').live('change', function() {
    // We should re-calculate based on the year/month drop down thinger.
    var finishedAt = $('#beer_finish_aging_at');
    var finishYearBox =  $('#beer_finish_aging_year');
    var finishMonthBox =  $('#beer_finish_aging_month');
    recalculateFinishDateFromYearAndMonth(finishedAt, $(this), finishMonthBox, finishYearBox);
});

$('#beer_finish_aging_at').live('change', function() {
    // We should re-calculate based on the year/month drop down thinger.
    var startedAt = $('#beer_cellared_at');
    var finishYearBox =  $('#beer_finish_aging_year');
    var finishMonthBox =  $('#beer_finish_aging_month');
    recalculateMonthsAndYearFromFinishDate($(this), startedAt, finishMonthBox, finishYearBox);
});

function recalculateFinishDateFromYearAndMonth(finishDateBox, startDateBox, monthDropDown, yearDropDown) {
    if(startDateBox.isEmpty()) {
        return;
    }
    
    // Make sure it's in the correct format too
    var startDate = startDateBox.val();
    if(!startDate.match(/^\d{4,4}\-\d{2,2}\-\d{2,2}$/)) {
        throw "Start date is in an incorrect format."
    }
    
    var components = startDate.split('-');
   
    var year = parseInt(components[0]);
    var month = parseInt(components[1]);
    
    // Month is the last one -- add time to it 
    var addedMonths = parseInt(monthDropDown.val()) + month;
    if(addedMonths > 12) {
        year += 1;
        addedMonths -= 12;
    }
    
    year += parseInt(yearDropDown.val());
    
    // Now re-assemble this and put it in the finishDateBox
    finishDateBox.val(year + '-' + addedMonths + '-' + components[2]);
}

function recalculateMonthsAndYearFromFinishDate(finishDateBox, startDateBox, monthDropDown, yearDropDown) {
    if(startDateBox.isEmpty()) {
        return;
    }
    
    // Make sure it's in the correct format too
    var startDate = startDateBox.val();
    if(!startDate.match(/^\d{4,4}\-\d{2,2}\-\d{2,2}$/)) {
        throw "Start date is in an incorrect format."
    }
    
    // Do the same thing for finishDateBox
    if(finishDateBox.isEmpty()) {
        return;
    }
    
    // Make sure it's in the correct format too
    var finishDate = finishDateBox.val();
    if(!finishDate.match(/^\d{4,4}\-\d{2,2}\-\d{2,2}$/)) {
        throw "Start date is in an incorrect format."
    }
    
    // Now calculate the delta in years and months
    var startComponents = startDate.split('-');
    var finishComponents = finishDate.split('-');
    
    // Whew.
    yearDropDown.val(parseInt(finishComponents[0]) - parseInt(startComponents[0]));
    monthDropDown.val(parseInt(finishComponents[1]) - parseInt(startComponents[1]));
}