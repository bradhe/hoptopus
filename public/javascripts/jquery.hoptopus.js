function setupDatePickers() {
  $('input.date').datepicker({
    dateFormat: 'yy-mm-dd',
    showButtonPanel: true,
    buttonImage: "/images/calendar.png",
    buttonImageOnly: false,
    changeYear: true,
    changeMonth: true
  }).each(function() {
    if(!$(this).data('has_img')) {
      var img = $('<img/>').attr('src', '/images/calendar.png').addClass('datepicker');
      $(this).after(img);
      $(this).data('has_img', true);
    }
  });
}

$.fn.showLoading = function() {
  var div = $('<div/>').addClass('loading-modal');
  $('<span/>').addClass('note').appendTo(div);
}

$.fn.isEmpty = function() {
  if(this.text() && !this.val()) {
    return (this.text() == '' || this.text().match(/^\s+$/));
  }
  else {
    return this.val && (this.val() == '' || this.val().match(/^\s+$/)); 
  }
}

$.fn.closeDropdown = function() {
  if($(this).data('popup') || $(this).hasClass('open')) {
    var div = $(this).data('popup');
    $(this).removeClass('open');
    div.hide();
  }
}

$.fn.tooltip = function(text) {
  if($(this).data('tooltip')) {
    return;
  }

  $(this).one('mouseover', function(e) {
    var span = $('<span/>').addClass('tooltip');
    span.css('position', 'absolute');
    span.css('left', e.pageX);
    span.css('top', e.pageY);
    span.text(text);

    $('body').append(span);
    $(this).data('tooltip', span);

    $('body').bind('mousemove.tooltip', function(e) {
      span.css('left', e.pageX);
      span.css('top', e.pageX);
    });

    $(this).one('mouseleave.tooltip', function() {
      $('body').unbind('mousemove.tooltip');
      span.remove();

      $(this).data('tooltip', null);
    });
  });
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

$(function() {
  $('input').focus(function() {
    $('input.open').each(function() {
      var div = $(this).data('popup');
      div.hide();
      $(this).removeClass('open');
    });
  });

  $('button[data-close-dialog]').bind('click', function() {
    $(this).parents('div.ui-dialog-content').dialog('close');
    var form = $(this).parents('form').first();

    if(form.length > 0) {
      form[0].reset();
    }

    // TODO: Fix this hack -- this is stupid.
    $(form).find('ul.errors').empty();
  });

  $('body').click(function(e) {
    $('input.open').closeDropdown();
    e.stopPropagation();
  });

  $('h3[data-hideable], h2[data-hideable]').each(function() {
    var id = $(this).attr('data-hideable');

    var div = $('div#'+id);
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

      return false;
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
    var attr = $(this).attr('data-tab-handle');

    var tab = $('#' + attr);

    // This is kind of fucked up. We have to remove the ID so that the thing doesn't
    // jump around when we change tabs, but we still need to be able to find the body
    // of this tab somehow. Thus, we add a class here, then we can find it with the
    // selected .tab.<attr>
    tab.addClass('tab ' + attr);
    tab.hide();

    // Remove this tab's ID I guess.
    tab.attr('id', '');

    $(this).click(function() {
      if(tab.is(':hidden')) {
        $('.tabs .open').removeClass('open');
        $(this).addClass('open');

        // Hide all the other tabs...
        $('.tab').hide();
        tab.show();

        // Set the hash so that we can come back here easily.
        window.location.hash = attr;
      }

      return false;
    });
  });

  var id = firstTab.attr('data-tab-handle');

  if(location.hash) {
    id = location.hash.substring(1);

    // If there is a ? then chop off everything after that
    if(id.indexOf('?') > 0) {
      id = id.substring(0, id.indexOf('?'));
    }

    // Finally, make sure that we can find this thing
    if(!id || $('.tab.' + id).length < 1) {
      id = firstTab.attr('data-tab-handle');
    }
  }

  // Make sure the first tab is open
  var tabContents = $('.tab.' + id);
  $('h2[data-tab-handle="'+id+'"]').addClass('open');
  tabContents.show();


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

  hoptopus.initJavascriptControls(document);

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

  //
  // Set up UI hints.
  $('input[title]').each(function() {
    var title = $(this).attr('title');
    var holder = $('<span class="holder"/>').text(title);

    if($(this).val() != '') {
      holder.addClass('hidden');
    }

    $(this).after(holder);

    $(this).focus(function() {
      holder.addClass('active');
    });

    $(this).blur(function() {
      holder.removeClass('active');
    });

    var that = this;
    holder.click(function() { that.focus(); });

    $(this).bind('keyup change', function() {
      console.log('val: ' + $(this).val() + ', ' + $(this).val().length);

      if($(this).val().length > 0) {
        holder.addClass('hidden');
      }
      else {
        holder.removeClass('hidden');
      }
    });
  });
});


$('.finish_aging_year').live('change', function() {
  // We shouldn't be further than a few parents away from the other box so go up by three or four parents.
  var parent = $(this).parent().parent().parent();

  var startedAt = parent.find('.cellared_at').first();
  var finishedAt = parent.find('.finish_aging_at').first();
  var finishMonthBox =  parent.find('.finish_aging_month').first();
  recalculateFinishDateFromYearAndMonth(finishedAt, startedAt, finishMonthBox, $(this));
});

$('.finish_aging_month').live('change', function() {
  var parent = $(this).parent().parent().parent();

  var startedAt = parent.find('.cellared_at').first();
  var finishedAt = parent.find('.finish_aging_at').first();
  var finishYearBox = parent.find('.finish_aging_year').first();
  recalculateFinishDateFromYearAndMonth(finishedAt, startedAt, $(this), finishYearBox);
});

$('.cellared_at').live('change', function() {
  var parent = $(this).parent().parent().parent();

  var finishedAt = parent.find('.finish_aging_at').first();
  var finishYearBox = parent.find('.finish_aging_year').first();
  var finishMonthBox = parent.find('.finish_aging_month').first();
  recalculateFinishDateFromYearAndMonth(finishedAt, $(this), finishMonthBox, finishYearBox);
});

$('.finish_aging_at').live('change', function() {
  var parent = $(this).parent().parent().parent();

  var startedAt = parent.find('.cellared_at').first();
  var finishYearBox = parent.find('.finish_aging_year').first();
  var finishMonthBox = parent.find('.finish_aging_month').first();
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
