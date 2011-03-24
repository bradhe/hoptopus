/**
 * Created by DA BWAD!!!!!!
 * User: brad.heller
 * Date: 3/21/11
 * Time: 12:14 AM
 */

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
  };
  
  this.clear = function() {
    $(this.textBox).val('');
  };
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
  };
  
  this.clear = function() {
    $(this.select).val('');
  };
}

function StringComparator(left, right) {
    if(jQuery.isString(left) && jQuery.isString(right)) {
        left = left.toLowerCase();
        right = right.toLowerCase();

        return left > right;
    }
    else {
        return false;
    }
}

function NumericComparator(left, right) {
  return left > right;
}

hoptopus.grid = function(options) {
    var g = {};
    var dropdown = null;
    var columnProperties = {};
    var filters = [];
    var filtersIndex = {};
    var sortedColumn = null;

    var settings = {
        columnAdded: null,
        columnRemoved: null,
        nameFormatter: null,
        sortable: false,
        dropdown: null,
        columns: null,
        table: null,
        rowClasses: ['color1','color2'],
        fadeInRows: false
    };

    // Merge objects
    if(options) {
        jQuery.extend(settings, options);
    }

    // This is reliant on settings.
    var dropdownButton = settings.dropdown;
    var columns = settings.columns;
    var grid = settings.table;

    // Instance variables.
    g.searchResults = null;
    g.rowClasses = [];
    g.objects = [];
    g.breweries = [];
    g.rowsShown = 0;

  function sortTableByColumn(th, column, objs) {
    var needsSort = true;

    // Clear the other objects that have sortable columns.
    if(sortedColumn != column) {
      // Clear this and get the new objects.
      grid.find('thead th.sorted').addClass('unsorted').removeClass('sorted');
      $(th).removeClass('unsorted').addClass('sorted down');

      if(!objs) {
        objs = g.objects;
      }
    }
    else if(sortedColumn) {
      if($(th).hasClass('down')) {
        $(th).removeClass('down');
        $(th).addClass('up');
      }
      else {
        $(th).removeClass('up');
        $(th).addClass('down');
      }

      if(!objs) {
        objs = g.objects.reverse();
      }

      needsSort = false;
    }
    else if(!objs) {
      objs = g.objects;
    }

    if(needsSort) {
      sortedColumn = column;

      var p = column.property;

      var comp = StringComparator;

      // TODO: This is gross. We should have a better way of determining data type.
      if(p == 'year') {
        comp = NumericComparator;
      }

      // Look up special cases for thing. If P starts with "formatted_" then strip that
      // and return a date comparator if it has a "_at" at the end.
      if(p.indexOf('formatted_') == 0) {
        p = p.substring('formatted_'.length);
      }

      objs = hoptopus.qsort(p, objs, comp);
    }

    return objs;
  }

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

    // Unsorted so just do this however.
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
      // Now that that's complete we need to sort the columns
      // again.
      var l = targets.length;
      var stickInQueue = false;
      if(l > n) {
        l = n;
        stickInQueue = true;
      }

      if(sortedColumn) {
        targets = sortTableByColumn([], sortedColumn, targets);
      }
      else {
        for(var i = 0; i < l; i++) {
          addObjectRow(targets[i], tbody);
        }
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

      if(jQuery.isFunction(settings.columnRemoved)) {
        settings.columnRemoved(th);
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

        var l = g.breweries.length;
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

      if(jQuery.isFunction(settings.columnAdded)) {
        settings.columnAdded(th);
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

      $(this).one('mouseleave', function() {
        timeout = setTimeout(function() {
            dropdown.hide();
        }, 1500);
      });

      dropdown.mouseenter(function() {
        window.clearTimeout(timeout);
      });

      $(this).mouseenter(function() {
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

    function addObjectRow(obj, tbody, front) {
      // Grab all the headers for the grid.
      var headers = grid.find('thead tr:first th');
      var selectedColumns = [];
      var classes = settings.rowClasses;
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

      // TODO: Clean this out, we should use something less domain-specific.
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
            if(column == 'name' && $.isFunction(settings.nameFormatter)) {
                td.append(settings.nameFormatter(obj));
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

        if(tbody && front) {
            tbody.prepend(tr);
        }
        else if(tbody) {
            tbody.append(tr);
        }

        return tr;
    }

    g.init = function() {
        if(dropdownButton) {
            $(dropdownButton).click(dropdownButtonClicked);
        }

        var div = $('<div/>').addClass('select-columns dropdown');

        // Cache the dropdown thing.
        // Get all the currently checked columns
        var checked = {};
        var headers = grid.find('thead th');

        if(options.sortable) {
            headers.addClass('unsorted');
        }

        for(var i = 0; i < headers.length; i++) {
            var th = headers[i];

            if($(th).attr('id')) {
                checked[$(th).attr('id')] = true;
            }
        }

        if(settings.sortable) {
            // Set up for sorting.
            headers.click(function() {
              var id = this.id;
              var column = null;

              for(var i in columns) {
                  var c = columns[i];
                  if(c.id == id) {
                      column = c;
                      break;
                  }
              }

              if(!column) {
                throw "No column with ID " + id + " was found.";
              }

              g.objects = sortTableByColumn(this, column);

              // TODO: This is a pretty shitty hack, fix it.
              g.rowsShown = 0;

              grid.children('tbody').empty();

              // Empty the body.
              g.moreRows(25);
            });
      }

      for(var i in columns) {
        var column = columns[i];
        columns[i].property = i;

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
    };

    g.clearFilters = function() {
      for(var i = 0; i < filters.length; i++) {
        filters[i].clear();
      }

      applyFilters();
    };

    g.addSingleObject = function(obj, options) {
        if(g.objects && $.isArray(g.objects)) {
            g.objects.push(obj);
        }

        // Add a single row to the grid.
        var front = false;
        if(options && options.front) {
            front = options.front;
        }

        var tbody = grid.find('tbody');
        return addObjectRow(obj, tbody, front);
    }

    // Init our object right before we leave this thing.
    g.init();

    return g;
}
