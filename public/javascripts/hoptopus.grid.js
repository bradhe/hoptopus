var hoptopus = (function($) {
  var h = {};
  var currentProgress = null;

  h.showProgress = function(text, fn) {
    if(currentProgress) {
      this.hideProgress();
    }

    var progressImg = $('<img/>').attr('src', '/images/progress-black.gif');

    var span = $('<span/>').addClass('progress');
    span.append($(progressImg));
    span.append(text);

    var left = ($(window).width() / 2) - (span.outerWidth() / 2)
    span.css('left', left);

    $('body').prepend(span);
    currentProgress = span;

    if(fn) {
      fn();
    }
  };

  h.hideProgress = function() {
    if(currentProgress != null) {
      $(currentProgress).remove();
      currentProgress = null;
    }
  };

  return h;
}(jQuery));

hoptopus.grid = (function($){ 
  var g = {};
  var columns = null;  
  var dropdownButton = null;
  var dropdown = null;
  var grid = null;
  var rowObjs = null;
  var columnAddedFn = null;
  var columnRemovedFn = null;
  var objectIndex = {};
  var columnProperties = {};
  
  // This is for a really terrible hack.
  var cellar = -1;

  function checkboxClicked(e) {
    var column = $(this).data('column');
    var property = $(this).data('property');

    if($(this).attr('checked')) {
      hoptopus.showProgress('Adding column...');
      addColumn(column, property, $(this).index());
      hoptopus.hideProgress();    
    }
    else {
      hoptopus.showProgress('Removing column...');
      removeColumn(column);
      hoptopus.hideProgress();
    }
    
    // Prevents the dropdown from being closed.
    e.stopPropagation();
  }

  function removeColumn(column) {
    var index = -1;
    var headers = grid.find('thead th');
    for(var i = 0; i < headers.length; i++) {
      var header = headers[i];
      
      if(header.id == column.id) {
        index = i;
        break;
      }
    }

    if(index < 0) {
      throw "No column with ID " + column.id + " was found.";
    }

    // keep the th to report the removal
    var th = null;

    // Remove this TH and all of the things out of the trs
    var rows = grid.find('tr');
    for(var i = 0; i < rows.length; i++) {
      var tr = rows[i];

      if(tr.children && tr.children.length >= index) {
        var child = tr.children[index];
      
        if(th == null) {
          th = child;
        }

        tr.removeChild(child);
      }
    }

    if(jQuery.isFunction(columnRemovedFn)) {
      columnRemovedFn(th);
    }

    var td = grid.find('tfoot td[colspan]');
    var colspan = parseInt(td.attr('colspan'));
    td.attr('colspan', colspan - 1);
  }

  function addColumn(column, property, insertAt) {
    if(!property) {
      throw "Property not supplied.";
    }

    var th = $('<th/>').addClass('header').text(column.title);
    $(th).attr('id', column.id);

    // TODO: Figure out where this should actually go. Do we really want italic
    // to be after the first unsortable?
    var actualTh = grid.find('thead th').last();

    var idx = $(actualTh).index();
    actualTh.after(th);
    
    // Get all the rows, a column to each row.
    var rows = grid.find('tbody tr');
    for(var i = 0; i < rows.length; i++) {
      var tr = rows[i];
      var beerId = $(tr).attr('data-beer');

      // lookup that beer from the objs.
      var beer = objectIndex[beerId];

      if(!beer) {
        throw "Beer with ID " + beerId + " was not found in row object collection.";
      }

      var actualTd = $(tr).children('td')[idx];
      var td = $('<td/>').text(beer[property] ? beer[property] : '');
      td.insertAfter(actualTd);
    }

    if(jQuery.isFunction(columnAddedFn)) {
      columnAddedFn(th);
    }

    // Increase the colspan on the footer row.
    var td = grid.find('tfoot td[colspan]');
    var colspan = parseInt(td.attr('colspan'));
    td.attr('colspan', colspan + 1);
  } 

  var timeout = null;
  function dropdownButtonClicked(e) {
    if($(this).hasClass('down')) {
      if(timeout) {
        window.clearTimeout(timeout);
      }
      
      $(this).removeClass('down');
      dropdown.hide();
      
      return false;
    }
    
    var offset = $(this).offset();
	  dropdown.css('top', offset.top + $(this).outerHeight());
  	dropdown.css('left', offset.left);
    $(this).addClass('down');
    
    if(columns == null) {
      throw "Column definitions not set";
    }

    var t = $(this);
    
    timeout = setTimeout(function() {
      dropdown.hide();
    }, 3000);

    dropdown.mouseenter(function() {
      window.clearTimeout(timeout);
    });

    dropdown.mouseleave(function() {
      timeout = setTimeout(function() {
        dropdown.hide();
        t.removeClass('down');
      }, 3000);
    });

    $('body').click(function() {
      dropdown.hide();
      t.removeClass('down');
    });
    
    dropdown.click(function(e) {
      e.stopPropagation();
    });

    e.stopPropagation();
    dropdown.show();
  }

  g.init = function(columnObj, dropdownObj, gridObj, callbacks, cellarId) {
    columns = columnObj;
    dropdownButton = dropdownObj;
    grid = gridObj;
    cellar = cellarId;
    
    $(dropdownButton).click(dropdownButtonClicked);

    // Do the callbacks thing.
    if(callbacks) {
      columnAddedFn = callbacks.columnAdded;
      columnRemovedFn = callbacks.columnRemoved;
    }

    var div = $('<div/>').addClass('select-columns dropdown');
    
    // Cache the dropdown thing.
    // Get all the currently checked columns
    var checked = {};
    var headers = grid.find('thead th');
    for(var i = 0; i < headers.length; i++) {
      var th = headers[i];

      if($(th).attr('id')) {
        checked[$(th).attr('id')] = true;
      }
    }

    for(var i in columns) {
      var column = columns[i];
      var checkbox = $('<input/>').attr('type', 'checkbox').attr('id', i + '-checkbox');
      checkbox.data('property', i);
      columnProperties[i] = column;

      var label = $('<label/>').attr('for', i + '-checkbox').text(column.title);
      $('<div/>').append(checkbox).append(label).appendTo(div);
      
      label.click(function(e) { e.stopPropagation(); });

      if(checked[column.id]) {
        checkbox.attr('checked', true);
      }

      checkbox.data('column', column);
      checkbox.bind('click', checkboxClicked);
    }

    dropdown = div;
    dropdown.hide();
    $(dropdownButton).after(dropdown);
  } 

  g.objects = function(objs) {
    rowObjs = objs;

    // Set the object index so that we can lookup objects.
    objectIndex = {};
    for(var i in objs) {
      var obj = objs[i];
  
      if(typeof(obj) == 'object' && obj.id) {
        objectIndex[obj.id] = obj;
      }
    }
  }
  
  g.addObjects = function(objs, rowClasses, rowClassStartingIndex) {
    // Grab all the headers for the grid.
    var headers = grid.find('thead tr:first th');
    var selectedColumns = [];
    
    if(!rowClassStartingIndex) {
      rowClassStartingIndex = 0;
    }
    
    if(!rowClasses) {
      rowClasses = [];
    }
    
    for(var i = 0; i < headers.length; i++) {
      var header = headers[i];
      
      if($(header).hasClass('unsortable')) {
        // TODO: Abstract this logic. For now, just mark this as the textbox column.
        selectedColumns.push({ checkbox: true });
      }
      else {
        for(var j in columns) {
          if(columns[j].id == header.id) {
            selectedColumns.push(j);
          }
        }
      }
    }

    var rowClassesN =  rowClasses.length;
    var tbody = grid.find('tbody');
    
    // Get the last TR here and figure out how each column should by styled.
    var columnStyles = {};
    var rows = tbody.find('tr:last');
    var cols = rows.find('td');
    for(var i = 0; i < cols.length; i++) {
      var td = $(cols[i]);
      columnStyles[i] = { valign: td.attr('valign'), align: td.attr('align') };
    }
    
    // Push all these objs on to the row objs
    for(var i = 0; i < objs.length; i++) {
      var obj = objs[i];
      rowObjs.push(obj);
      
      var tr = $('<tr/>');
      tr.attr('data-beer', obj.id);
      var cls = rowClasses[(i + rowClassStartingIndex) % rowClassesN];
      
      if(cls) {
        tr.addClass(cls);
      }
      
      for(var j = 0; j < selectedColumns.length; j++) {
        var column = selectedColumns[j];
        
        var td = $('<td/>');
        if(typeof(column) == 'object' && 'checkbox' in column) {
          var input = $('<input/>').attr('type', 'checkbox').attr('name', 'selected_beers').val(obj.id);
          td.attr('valign', 'middle');
          td.attr('align', 'center');
          td.append(input);
        }
        else {
          // TODO: Fix this hack for name.
          if(column == 'name') {
            var a = $('<a/>').attr('href', '/cellars/'+cellar+'/beers/'+obj.id).text(obj[column]);
            td.append(a);
          }
          else {
            td.text(obj[column]);
          }
        }
        
        // We should see if this has any styling to it.
        var style = columnStyles[j];
        for(var k in columnStyles[j]) {
          if(style[k]) {
            td.attr(k, style[k]);
          }
        }
        
        tr.append(td);
      }
      
      tbody.append(tr);
    }
  }

  return g;
})(jQuery);
