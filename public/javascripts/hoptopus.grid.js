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

function GenericFilter(textBox, propertyName) {
  this.textBox = textBox;
  this.propertyName = propertyName;
  this.filter = function(objs) {
    var oc = objs.length;
    // get the val and clean it up. We will fuzzy-match this stuff.
    var val = $(this.textBox).val();
    var clean = val.replace(/\s+/g, '');

    if(!clean) {
      return objs;
    }

    clean = clean.toLowerCase();

    var found = [];
    for(var i = 0; i < objs.length; i++) {
      if(!(this.propertyName in objs[i])) {
        continue;
      }

      var n = objs[i][this.propertyName].replace(/\s+/g, '');

      if(!n) {
        continue;
      }

      n = n.toLowerCase();

      // Can appear anywhere in the thing.
      if(n.indexOf(clean) > -1) {
        found.push(objs[i]);
      }
    }

    return found;
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
      if(objs[i].brewery == val) {
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
  if(typeof(left) == 'string' && typeof(right) == 'string') {
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
    fadeInRows: false,
    pageSize: 25,
    pagesList: 'div.pages',
    checkBoxClicked: null
  };

  // Merge objects
  if(options) {
    jQuery.extend(settings, options);
  }

  // This is reliant on settings.
  var dropdownButton = settings.dropdown;
  var columns = settings.columns;
  var grid = settings.table;

  // Merge the properties in to the columns
  for(var i in columns) { columns[i].property = i; }

  // Instance variables.
  g.searchResults = null;
  g.rowClasses = [];
  g.beers = [];
  g.breweries = [];
  g.rowsShown = 0;

  function sortTableByColumn(th, column, objs, direction) {
    var p = column.property;
    var comp = StringComparator;

    // TODO: This is gross. We should have a better way of determining data type.
    if(p == 'year') {
      comp = NumericComparator;
    }

    if(objs == null) {
      objs = g.beers;
    }

    // Look up special cases for thing. If P starts with "formatted_" 
    // then strip that // and return a date comparator if it has a 
    // "_at" at the end.
    if(p.indexOf('formatted_') == 0) {
      p = p.substring('formatted_'.length);
    }

    objs = hoptopus.qsort(p, objs, comp);

    if(direction == 'up') {
      objs = objs.reverse();
    }

    return objs;
  }

  var allObjects = null;

  function applyFilters() {
    // Bind this thing.
    var tbody = grid.find('tbody');
    tbody.empty();

    var n = 25; // TODO: Fix this so that it's not static.

    var l = filters.length
    var targets = allObjects || g.beers;

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

      // Clear the buttons and everything
      $("#pages span.page-numbers").empty();
      $("#pages span.next").empty();
      $("#pages span.prev").empty();
    }
    else {
      // Save all these if they have not been saved before.
      if(allObjects == null) {
        allObjects = g.beers;
      }

      g.beers = targets;
      g.repopulateTable();
      g.resetSort();
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
      objs = g.beers;
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
    else if(property == 'brewery') { // Brewery
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

    var tr = $('<tr/>').attr('data-beer', obj.id);

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

        if($.isFunction(settings.checkBoxClicked)) {
          input.click(settings.checkBoxClicked);
        }

        // These are default.
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

  function setNextAndPrev(div) {
    // Start with next
    var nextSpan = div.find('span.next');
    var prevSpan = div.find('span.prev');

    var pageNumber = parseInt(div.attr('data-page-number') || '1');
    nextSpan.empty();
    prevSpan.empty();

    if(pageNumber > 1) {
      var prevA = $('<a/>').attr('href', 'javascript:void(0);').html('&laquo; Prev');
      prevSpan.append(prevA);
      prevA.click(function() { goToPage(pageNumber-1, div); });
    }

    var totalPages = Math.round(g.beers.length / settings.pageSize) + (g.beers.length % settings.pageSize > 0 ? 1 : 0);
    if(pageNumber < totalPages) {
      var nextA = $('<a/>').attr('href', 'javascript:void(0);').html('Next &raquo;');
      nextSpan.append(nextA);
      nextA.click(function() { goToPage(pageNumber+1, div); });
    }
  }

  function getNumberOfPages() {
    return Math.round(g.beers.length / settings.pageSize) + (g.beers.length % settings.pageSize > 0 ? 1 : 0);
  }

  function goToPage(pageNumber, div) {
    var start = settings.pageSize * (parseInt(pageNumber) - 1);
    var end = start + settings.pageSize;

    var tbody = grid.find('tbody');
    tbody.empty();

    for(var i = start; i < end; i++) {
      if(g.beers[i] == undefined) {
        continue;
      }

      addObjectRow(g.beers[i], tbody);
    }

    var span = div.find('span.page-numbers');
    span.find('a.selected').removeClass('selected');

    var as = span.find('a');
    for(var i = 0; i < as.length; i++) {
      var a = $(as[i]);

      if(parseInt(a.text()) == pageNumber) {
        a.addClass('selected');
        break;
      }
    }

    div.attr('data-page-number', pageNumber);
    setNextAndPrev(div);
  }

  function createPages() {
    var numberPages = getNumberOfPages();

    var span = grid.parent().parent().find(settings.pagesList).find('span.page-numbers');
    span.empty();

    for(var i = 0; i < numberPages; i++) {
      var a = $('<a/>').attr('href', 'javascript:void(0);').text(i+1);
      span.append(a);

      // TODO: Add click handler here.
      a.click(function() {
        span.find('a').removeClass('selected');
        $(this).addClass('selected');

        var pageNumber = $(this).text();
        goToPage(pageNumber, span.parent());
      });
    }

    span.find('a').first().addClass('selected');
    setNextAndPrev(span.parent());
  }

  //
  // Add the first pageSize of the beers collection to the
  // table.
  g.repopulateTable = function() {
    var tbody = grid.children('tbody');
    tbody.empty();

    for(var i = 0; i < settings.pageSize; i++) {
      if(g.beers[i] == undefined) {
        continue;
      }

      addObjectRow(g.beers[i], tbody);
    }

    createPages();
  }

  g.resetSort = function() {
    grid.find('th').removeClass('sorted up down');
  }

  g.sortBy = function(id, direction) {
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

    g.beers = sortTableByColumn(this, column, null, direction);
  }

  g.init = function(options) {
    g.beers = options.beers;
    g.breweries = options.breweries;

    var headers = grid.find('thead th');

    if(settings.sortable) {
      headers.addClass('unsorted');
      headers.click(function() {
        var sortDirection = 'down';

        if($(this).hasClass('sorted up')) {
          sortDirection = 'down';
        }
        else if($(this).hasClass('sorted down')) {
          sortDirection = 'up';
        }

        g.resetSort();
        $(this).addClass('sorted ' + sortDirection);

        var id = this.id;
        g.sortBy(id, sortDirection);
        g.repopulateTable();
      });
    }

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
            if(t) { window.clearTimeout(t); }
            t = window.setTimeout(applyFilters, 75);
          }
        }());
      }
      else if(property == 'brewery') {
        var select = $(filterColumns[i].children[0]);
        filter = new BreweryFilter(select);
        select.change(applyFilters);
      }
      else {
        var input = $(filterColumns[i].children[0]);
        filter = new GenericFilter(input, property);
        input.keyup(function() {
          var t = null;
          return function() {
            if(t) { window.clearTimeout(t); }
            t = window.setTimeout(applyFilters, 75);
          }
        }());
      }

      if(filter) {
        filtersIndex[property] = filters.push(filter);
      }
    }

    // Add a number of rows to the thing.
    this.repopulateTable();
  }

  //
  // Clear all of the search filters.
  g.clearFilters = function() {
    for(var i = 0; i < filters.length; i++) {
      filters[i].clear();
    }

    g.beers = allObjects;
    allObjects = null;
  };

  //
  // Add a single new object to the internal list of objects.
  g.addSingleObject = function(obj, options) {
    if($.isArray(g.beers)) {
      g.beers.push(obj);
    }

    // Add a single row to the grid.
    var front = false;
    if(options && options.front) {
      front = options.front;
    }

    var tbody = grid.find('tbody');
    return addObjectRow(obj, tbody, front);
  }

  return g;
}
