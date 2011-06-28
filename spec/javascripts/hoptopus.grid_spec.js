describe("hoptopus.grid", function() {
  var grid;
  var table;

  var boringBeers = [
    {"some_property": "x", "some_other_property": "x"},
    {"some_property": "x", "some_other_property": "x"},
    {"some_property": "x", "some_other_property": "x"},
    {"some_property": "x", "some_other_property": "x"},
    {"some_property": "x", "some_other_property": "x"},
    {"some_property": "x", "some_other_property": "x"}
  ];

  var realBeers = [
    {"some_property": "b", "some_other_property": "x"},
    {"some_property": "c", "some_other_property": "x"},
    {"some_property": "t", "some_other_property": "x"},
    {"some_property": "v", "some_other_property": "x"},
    {"some_property": "k", "some_other_property": "x"},
    {"some_property": "a", "some_other_property": "x"}
  ];

  var lotsOfBeers = [];
  for(var i = 1; i <= 50; i++) {
    lotsOfBeers.push({"some_property": i, "some_other_property": i*2});
  }

  beforeEach(function() {
    loadFixtures("hoptopus_grid.html");

    table = $("#test-table");
    grid = hoptopus.grid({
      columns: {
        "some_property": {
          'id': 'property1',
          'name': 'First Property'
        },
        "some_other_property": {
          'id': 'property2',
          'name': 'Second Property'
        }
      },
      table: table,
      sortable: true
    });
  });

  describe('.repopulateTable', function() {
    beforeEach(function() {
      grid.init({ beers: boringBeers });
      table.find('tbody').empty();
    });

    it('should be able to repopulate the body', function() {
      grid.repopulateTable();
      expect(table.find("tbody tr").length).toEqual(6); // Default page size.
    });
  });

  describe('sorting', function() {
    beforeEach(function() {
      grid.init({ beers: realBeers });
    });

    it('should be able to sort objects', function() {
      grid.sortBy('property1');
      expect(grid.beers[0].some_property).toBe('a');
    });

    it('should be able to sort objects descendingly too', function() {
      grid.sortBy('property1', 'up');
      expect(grid.beers[0].some_property).toBe('v');
    });

    it('should sort when header is clicked', function() {
      clickFirstHeader(table);
      expect(table.find('tbody td:first')).toHaveText('a');
    });

    it('should set the header to sorted when a header is clicked', function() {
      clickFirstHeader(table);
      expect(firstHeader(table)).toHaveClass('sorted down');
    });

    it('should clear other headers sorted status if a different header is clicked', function() {
      clickFirstHeader(table);
      clickLastHeader(table);
      expect(firstHeader(table)).not.toHaveClass('sorted');
    });
  });

  describe('pagination', function() {
    beforeEach(function() {
      grid.init({ beers: lotsOfBeers });
    });

    it('should create pages in the pages thinger', function() {
      expect($("span.page-numbers")).not.toBeEmpty();
    });

    it('should show the second page when the page number is clicked', function() {
      var links = $("span.page-numbers a")
      $(links[1]).click();

      // Second page
      expect(table.find('tbody td:first')).toHaveText("26");
    });

    it('should maintain sort order during pagination', function() {
      // Sort, then go to next page
      clickFirstHeader(table);
      clickFirstHeader(table);
      goToPage(2);

      // Should be 25, the end of hte last page
      expect(table.find('tbody td:first')).toHaveText("25");
    });
  });

  function clickFirstHeader(table) {
    firstHeader(table).click();
  }

  function clickLastHeader(table) {
    lastHeader(table).click();
  }

  function firstHeader(table) {
    return table.find('th:first');
  }

  function lastHeader(table) {
    return table.find('th:last');
  }

  function goToPage(number) {
    var links = $("span.page-numbers a")
    $(links[number-1]).click();
  }
});
