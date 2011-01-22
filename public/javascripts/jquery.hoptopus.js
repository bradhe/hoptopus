
$.fn.showLoading = function() {
	var div = $('<div/>').addClass('loading-modal');
	$('<span/>').addClass('note').appendTo(div);
}

$("button[data-confirm], input[data-confirm]").live('click', function(e) {
	return confirm($(this).attr('data-confirm'));
});

$(document).ready(function() {
	$('h3[data-hideable]').each(function() {
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
});