
$.fn.showLoading = function() {
	var div = $('<div/>').addClass('loading-modal');
	$('<span/>').addClass('note').appendTo(div);
}

$.fn.isEmpty = function() {
    return this.val && (this.val() == '' || this.val().match(/^\s+$/));
}

$.fn.closeDropdown = function() {
	if($(this).data('popup') || $(this).hasClass('open')) {
		var div = $(this).data('popup');
		$(this).removeClass('open');
		div.hide();
	}
}

$.fn.dropdown = function(element) {	
	if($(this).hasClass('open')) {
		$(this).closeDropdown();
		
		e.stopPropagation();
		return false;
	}
	
	// All the other open ones, remove the popup
	$('input.open').closeDropdown();
	$(this).addClass('open');
	
	// Make a brewery list here
	var div = $('<div/>').addClass('dropdown');
	div.append(element);

	var offset = $(this).parent().offset();
	div.css('top', offset.top + $(this).parent().outerHeight());
	div.css('left', offset.left);
	div.width($(this).width());
	
	$(this).after(div);
	
	$(this).data('popup', div);
}

$('input.open').live('click', function(e) {
	e.stopPropagation();
	return false;
});

$("button[data-confirm], input[data-confirm]").live('click', function(e) {
	return confirm($(this).attr('data-confirm'));
});

$(document).ready(function() {
	$('input').focus(function() {
		$('input.open').each(function() {
			var div = $(this).data('popup');
			div.hide();
			$(this).removeClass('open');
		});
	});
	
	$('body').click(function(e) {
		$('input.open').closeDropdown();
		e.stopPropagation();
	});
	
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
		$('html, body').animate({scrollTop:0}, 0);
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
  
  $('input.date').datepicker({
      dateFormat: 'yy-mm-dd',
      showButtonPanel: true,
      buttonImage: "/images/calendar.png",
      buttonImageOnly: false,
      changeYear: true,
      changeMonth: true
  });
  
  $('input.date').each(function() {
      var img = $('<img/>').attr('src', '/images/calendar.png').addClass('datepicker');
      $(this).after(img);
  });

  // Add dismiss buttons for alerts
  $('div.alert').each(function() {  
    var img = new Image();
    img.src = '/images/x.png';
    img = $(img).attr('border', '0');

    var a = $('<a/>').attr('href', 'javascript:void(0);').addClass('dismiss-alert');
    a.append(img);

    a.click(function() {
      $(this).parents('div.alert').fadeOut('fast', function() {
        $.ajax({
          url: '/alerts/dismiss',
          type: 'POST',
          data: { 'name': $(this).attr('data-alert-name') }
        });
      }); 
    });
  
    $(this).prepend(a);
  }); 
});
