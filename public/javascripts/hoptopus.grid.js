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

// TODO: Abstract out these filters. D'oh.
function VarietyFilter(textBox) {
  this.textBox = textBox;
  this.filter = function(objs) {
    var oc = objs.length;
    // get the val and clean it up. We will fuzzy-match this stuff.
    var val = $(this.textBox).val();
    var clean = val.replace(/\s+/g, '');
    
    if(!clean) {
      return objs;
    }
    
    // thunk that bitch.
    clean = clean.toLowerCase();
    
    var found = [];
    for(var i = 0; i < objs.length; i++) {
      var n = objs[i].name.replace(/\s+/g, '');
      
      if(!n) {
        continue;
      }
      
      n = n.toLowerCase();
      if(n.indexOf(clean) == 0) {
        found.push(objs[i]);
      }
    }

    return found;
  }
  
  this.clear = function() {
    $(this.textBox).val('');
  }
}

function BreweryFilter(select) {
  this.select = select;
  
  this.filter = function(objs) {
    var oc = objs.length;
    var val = $(this.select).val();
    
    if(!val) {
      return objs;
    }
    
    var found = [];
    for(var i = 0; i < objs.length; i++) {
      if(objs[i].brewery_name == val) {
        found.push(objs[i]);
      }
    }

    return found;
  }
  
  this.clear = function() {
    $(this.select).val('');
  }
}

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
  var filters = [];
  var filtersIndex = {};
  g.searchResults = null;

  // This is for a really terrible hack.
  var cellar = -1;
  
  function applyFilters() {
    // Bind this thing.
    var tbody = grid.find('tbody');
    tbody.empty();
    
    var n = 25; // TODO: Fix this so that it's not static.
    
    var l = filters.length
    var targets = g.objects;
    
    for(var i = 0; i < l; i++) {
      targets = filters[i].filter(targets);
    }
    
    if(targets.length < 1) {
      var tr = $('<tr/>');
      var td = $('<td/>').attr('colspan', grid.find('thead tr:first th').length);
      td.addClass('empty');
      td.text('No beers found with that criteria.');
      tr.append(td);
      tbody.append(tr);
      
      // Also hide the button
      grid.find('tfoot button').hide();
    }
    else {
      var l = targets.length;
      var stickInQueue = false;
      if(l > n) {
        l = n;
        stickInQueue = true;
      }
      
      for(var i = 0; i < l; i++) {
        addObjectRow(targets[i], tbody);
      }
      
      // Take all the others and put them in the search results queue.
      if(stickInQueue) {
        g.searchResults = targets.slice(n);
        
        // Set up the "more" bit.
        var btn = grid.find('tfoot button');
        var txt = btn.text();
        txt = txt.replace(/\d{1,}/, g.searchResults.length);
        btn.text(txt);
        btn.show();
        
        // Set the rowsShown bit too
        g.rowsShown = n;
      }
      else {
        grid.find('tfoot button').hide();
      }
    }
  }

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
  
  // Quick binary search implementation. Man I'm awesome.
  function findObjectById(id, objs) {
    if(typeof(objs) == 'undefined') {
      objs = g.objects;
    }
    
    var i = Math.floor(objs.length / 2);
    if(objs[i].id == id) {
      return objs[i];
    }
    else if(objs.length <= 1) {
      return false;
    }
    
    // search the top array and the bottom array
    var top = objs.slice(i);
    var bottom = objs.slice(0, i);
    
    var topResult = findObjectById(id, top);
    var bottomResult = findObjectById(id, bottom);
    
    if(topResult) {
      return topResult;
    }
    else if(bottomResult) {
      return bottomResult;
    }
    
    // Didn't find it at all.
    return false;
  }

  function addColumn(column, property, insertAt) {
    if(!property) {
      throw "Property not supplied.";
    }

    var th = $('<th/>').addClass('header').text(column.title);
    $(th).attr('id', column.id);

    // TODO: Figure out where this should actually go. Do we really want italic
    // to be after the first unsortable?
    var actualTh = grid.find('thead th:last');

    var idx = $(actualTh).index();
    actualTh.after(th);
    
    // Also add a thing to the end of the filters line. If this is a special case,
    // then we ened to add a filter object for it.
    var filterTd = $('<td/>');
    
    if(property == 'name') { // Variety
      var input = $('<input/>').attr('name', 'search-cellar[variety]').attr('id', 'search-cellar-variety');
      filtersIndex[column.id] = filters.push(new VarietyFilter(input));
      filterTd.append(input);
      
      filterTd.attr('data-filter-for', property);
      input.keypress(applyFilters);
    }
    else if(property == 'brewery_name') { // Brewery
      var select = $('<select/>').attr('id', 'search-cellar-brewery');
      filtersIndex[column.id] = filters.push(new BreweryFilter(select));
      
      var l = hoptopus.grid.breweries.length;
      select.append(new Option());
      
      for(var i = 0; i < l; i++) {
        var name = g.breweries[i].name;
        select.append(new Option(name, name));
      }
      
      filterTd.attr('data-filter-for', property);
      filterTd.append(select);
      select.change(applyFilters);
    }
    
    var td = grid.find('thead tr:last td')[idx];
    $(td).after(filterTd);
    
    // Get all the rows, a column to each row.
    var rows = grid.find('tbody tr');
    for(var i = 0; i < rows.length; i++) {
      var tr = rows[i];
      var beerId = $(tr).attr('data-beer');

      // lookup that beer from the objs.
      var beer = findObjectById(beerId);
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
    }, 1500);

    dropdown.mouseenter(function() {
      window.clearTimeout(timeout);
    });

    dropdown.mouseleave(function() {
      timeout = setTimeout(function() {
        dropdown.hide();
        t.removeClass('down');
      }, 1500);
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
  
  function addObjectRow(obj, tbody) {
    // Grab all the headers for the grid.
    var headers = grid.find('thead tr:first th');
    var selectedColumns = [];
    var classes = hoptopus.grid.rowClasses;
    var lastRow = $(tbody.find('tr:last'));    
    var nextClass = '';
    
    for(var i = 0; i < classes.length; i++) {
      if(lastRow.hasClass(classes[i])) {
        nextClass = classes[(i + 1) % classes.length];
      }
    }
    
    if(!nextClass && classes.length > 0) {
      nextClass = classes[0];
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
    
    
    var tr = $('<tr/>');
    tr.attr('data-beer', obj.id);

    if(nextClass) {
      tr.addClass(nextClass);
    }
    
    // Get the last TR here and figure out how each column should by styled.
    var columnStyles = {};
    var rows = tbody.find('tr:last');
    var cols = rows.find('td');
    for(var i = 0; i < cols.length; i++) {
      var td = $(cols[i]);
      columnStyles[i] = { valign: td.attr('valign'), align: td.attr('align') };
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
      
      if(tbody) {
        tbody.append(tr);
      }
    }
  }

  g.rowClasses = [];
  g.objects = [];
  g.breweries = [];
  g.rowsShown = 0;
  
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
    
    // Setup the filters.
    var filterColumns = grid.find('thead tr.filters td[data-filter-for]');
    for(var i = 0; i < filterColumns.length; i++) {
      var property = $(filterColumns[i]).attr('data-filter-for');
      
      var filter = null;
      if(property == 'name') {
        var input = $(filterColumns[i].children[0]);
        filter = new VarietyFilter(input);
        input.keyup(function() {
          var t = null;
          return function() {
            if(t) {
              window.clearTimeout(t);
            }
            
            t = window.setTimeout(applyFilters, 75);
          }
        }());
      }
      else if(property == 'brewery_name') {
        var select = $(filterColumns[i].children[0]);
        filter = new BreweryFilter(select);
        select.change(applyFilters);
      }
      
      if(filter) {
        filtersIndex[property] = filters.push(filter);
      }
    }
  } 

  g.moreRows = function(n) {
    var tbody = grid.find('tbody');
    
    var t = g.rowsShown + n;
    for(var i = g.rowsShown; i < t; i++) {
      var obj = null;
      
      if(g.searchResults) {
        obj = g.searchResults[i];
      }
      else {
        obj = g.objects[i];
      }
      
      if(obj) {
        addObjectRow(obj, tbody);
      }
    }
    
    g.rowsShown = t;
  }
  
  g.clearFilters = function() {
    for(var i = 0; i < filters.length; i++) {
      filters[i].clear();
    }
    
    applyFilters();
  }

  return g;
})(jQuery);
