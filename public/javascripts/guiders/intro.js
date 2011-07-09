$(function() {
  function introDone() {
    guiders.hideAll();

    $.ajax({
      url: '/alerts/dismiss',
      type: 'POST',
      data: { 'name': 'getting_started' }
    });
  }
  guiders.createGuider({
    buttons: [{name: "No thanks, I don't need a tour.", onclick: introDone }, {name: "Next"}],
    description: "<p>This tour will help you get started with Hoptopus.</p><p>By the end you should know everything you need to get started using Hoptopus!</p>",
    id: "guider-intro",
    next: "guider-dashboard",
    title: "Welcome to Hoptopus!"
  }).show();

  guiders.createGuider({
    buttons: [{name: "Next"}],
    description: "<p>From here you can control everything about your Hoptopus account.</p><p>You can quickly get information about your beer collection and the beer collections of the people you're watching.</p>",
    id: "guider-dashboard",
    next: "guider-cellar",
    title: "This is your <em>Dashboard</em>"
  });

  guiders.createGuider({
    attachTo: "h2[data-tab-handle]:first",
    buttons: [{name: "Next"}],
    description: "<p>A cellar is just a beer collection.</p><p>Once you add all your beers to your Hoptopus cellar you will be able to quickly and easily <strong>search, filter, sort, and share</strong> your cellar.</p>",
    id: "guider-cellar",
    next: 'guider-add-beer',
    position: 6,
    title: "This is your <em>Cellar</em>"
  });

  guiders.createGuider({
    attachTo: "div.buttons div.left:first",
    buttons: [{name: "Next"}],
    description: "<p>Add beers individually with the <strong>Add Beer</strong> button.</p><p>If you are already keeping track of your cellar with a spreadsheet, click the <strong>Import</strong> button to add them all at once.",
    id: "guider-add-beer",
    next: 'guider-edit-beer',
    position: 3,
    width: 500,
    title: "This is how you <em>Add Beer to your Cellar</em>",
  });

  guiders.createGuider({
    attachTo: "div.buttons div.left:last",
    buttons: [{name: "Next"}],
    description: "<p>Once you add your beer collection to your cellar you will, eventually, need to make changes to it.</p><p>Use the <strong>Edit Selected</strong> button to edit one or more beers in your cellar. You can remove one or more beers with the <strong>Remove Selected</strong> button.</p><p>If you want to file a tasting note for a beer select it in your cellar and click <strong>New Tasting Note</strong>.",
    id: 'guider-edit-beer',
    next: 'guider-watches',
    position: 6,
    width: 600,
    title: "This is how you <em>Change the Beers in your Cellar</em>",
  });

  guiders.createGuider({
    attachTo: "h2[data-tab-handle]:nth-child(3)",
    buttons: [{name: "Next"}],
    description: "<p>When you find another user that has a cellar that you find interesting you can <strong>Watch</strong> that cellar.</p><p>In the <strong>Watched Recent Changes</strong> tab of your dashboard you will see updates when they add, remove, or change a beer in their cellar.</p>",
    id: 'guider-watches',
    next: 'guider-search',
    position: 6,
    width: 600,
    title: "This is where you <em>Watch Other Cellars</em>",
  });

  guiders.createGuider({
    attachTo: "#navigation div.search",
    buttons: [{name: "Great! I'm ready to get started!", onclick: introDone }],
    description: "<p>Search for the people you know by username, first name, and last name.</p><p>Once you find them, click the <strong>Watch</strong> button and you will receive updates when they add, remove, or change beers in their cellar.</p>",
    id: 'guider-search',
    position: 6,
    width: 500,
    title: "This is how you <em>Find People You Know</em>",
  });
});
