
$.fn.showLoading = function() {
	var div = $('<div/>').addClass('loading-modal');
	$('<span/>').addClass('note').appendTo(div);
}

$("button[data-confirm], input[data-confirm]").live('click', function(e) {
	return confirm($(this).attr('data-confirm'));
});

$(document).ready(function() {
	$('h3[data-hideable], h2[data-hideable]').each(function() {
		var div = $('div#'+$(this).attr('data-hideable'));
		div.hide();
		
		var img = new Image();
		img.src = '/images/plus.png';
		img.border = 0;
		
		var a = $('<a/>').attr('href', 'javascript:void(0);');
		a.append(img);
		a.append($(this).text());
		
		$(this).empty();
		$(this).append(a);
		
		a.click(function() {
			if(div.is(':hidden')) {
				img.src = '/images/minus.png';
				div.slideDown('fast');
			}
			else {
				img.src = '/images/plus.png';
				div.slideUp('fast');
			}
		});
	});
	
	$("table[data-sortable]").each(function(i) {
		var headers = {};
		$(this).find('th').each(function(i) {
			if($(this).hasClass('unsortable')) {
				headers[i] = { sorter: false };
			}
		});
		
		$(this).tablesorter({headers: headers});
	});
	
	// Set up and tabs on the page.
	var firstTab = $('h2[data-tab-handle]').first();
	var tabs = $('<div/>').addClass('tabs');
	
	firstTab.before(tabs);
	tabs.append($('h2[data-tab-handle]'));

	$('h2[data-tab-handle]').each(function() {
		var tab = $('#' + $(this).attr('data-tab-handle'));
		tab.addClass('tab');
		tab.hide();
		
		$(this).click(function() {
			if(tab.is(':hidden')) {
				$('.tabs .open').removeClass('open');
				$(this).addClass('open');
				$('.tab').hide();
				tab.show();
			}
		});
	});
	
	// Make sure the first tab is open
	var tabContents = $('#' + firstTab.attr('data-tab-handle'));
	firstTab.addClass('open');
	tabContents.show();
	
	window.setTimeout(function() { $('div.notice').fadeOut(2000, function() { $(this).remove(); }); }, 1000);
});