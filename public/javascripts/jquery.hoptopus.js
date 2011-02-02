
$.fn.showLoading = function() {
	var div = $('<div/>').addClass('loading-modal');
	$('<span/>').addClass('note').appendTo(div);
}

$.fn.isEmpty = function() {
    return this.val && (this.val() == '' || this.val().match(/^\s+$/));
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
	
	var id = firstTab.attr('data-tab-handle');
	
	if(location.hash) {
		id = location.hash.substring(1)
		
		// If there is a ? then chop off everything after that
		if(id.indexOf('?') > 0) {
			id = id.substring(0, id.indexOf('?'));
		}
		
		// Finally, make sure that we can find this thing
		if(!id || $('#' + id).length < 1) {
			id = firstTab.attr('data-tab-handle');
		}
		$('html, body').animate({scrollTop:0}, 'slow');
	}
	
	// Make sure the first tab is open
	var tabContents = $('#' + id);
	$('h2[data-tab-handle="'+id+'"]').addClass('open');
	tabContents.show();
	
	window.setTimeout(function() { $('div.notice').fadeOut(2000, function() { $(this).remove(); }); }, 1000);
    
    // Set up comment stuff
    $('button.leave-comment[data-comment-box]').each(function() {
        var button = $(this);
        var commentBox = $('#' + $(this).attr('data-comment-box'));
        
        if(!commentBox) {
            return;
        }
        
        commentBox.keypress(function() {
            if($(this).isEmpty()) {
                button.attr('disabled', true);
            }
            else {
                button.removeAttr('disabled');
            }
        });
        
        if(commentBox.isEmpty()) {
            button.attr('disabled', true);
        }
    });
});