describe("populateFirstPage", function() {
  it('should know the truth', function() {
    loadFixtures("hoptopus_grid.html");

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
      table: $("#test-table")
    });

    grid.init({
      beers:[
        {"some_property": "x", "some_other_property": "x"},
        {"some_property": "x", "some_other_property": "x"},
        {"some_property": "x", "some_other_property": "x"},
        {"some_property": "x", "some_other_property": "x"},
        {"some_property": "x", "some_other_property": "x"},
        {"some_property": "x", "some_other_property": "x"}
      ]
    });

    $("#test-table").find('tbody').empty();
    grid.repopulateTable();
    expect($("#test-table tbody tr").length).toBe(6);
  });
});
