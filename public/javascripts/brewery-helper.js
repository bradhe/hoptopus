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

$('select#brewery, select#beer_brewery_id').live('change', function() {
	var selectBrews = $('select#beer_brew_id');
	var button = $('#add-beer');
	
	if(!selectBrews) {
		throw "Couldn't find brews list.";
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