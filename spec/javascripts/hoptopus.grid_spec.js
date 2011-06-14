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

  it('should be able to repopulate the body', function() {
    grid.init({ beers: boringBeers });

    table.find('tbody').empty();
    grid.repopulateTable();
    expect(table.find("tbody tr").length).toBe(6);
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
      var th = table.find('th').first();
      th.click();

      expect(table.find('tbody td').first().text()).toBe('a');
    });

    it('should set the header to sorted when a header is clicked', function() {
      var th = table.find('th').first();
      th.click();

      expect(th).toHaveClass('sorted down');
    });

    it('should clear other headers sorted status if a different header is clicked', function() {
      var th = table.find('th').first();
      th.click();

      expect(th).toHaveClass('sorted');

      // Click the other one...
      table.find('th').last().click();

      expect(th).not.toHaveClass('sorted');
    });
  });

  describe('pagination', function() {
    beforeEach(function() {
      grid.init({ beers: lotsOfBeers });
    });

    it('should paginate to the correct page size', function() {
      var size = table.find('tbody tr').length;

      // Default page size = 25
      expect(size).toBe(25);
    });

    it('should paginate to the correct page size', function() {
      var size = table.find('tbody tr').length;

      // Default page size = 25
      expect(size).toBe(25);
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
      var th = table.find('th:first');
      th.click();

      // Sort down.
      th.click();

      // Second page
      var links = $("span.page-numbers a")
      $(links[1]).click();

      // Should be 25, the end of hte last page
      expect(table.find('tbody td:first')).toHaveText("25");
    });
  });
});
