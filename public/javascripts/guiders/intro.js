$(function() {
  guiders.createGuider({
    buttons: [{name: "No thanks, I don't need a tour."}, {name: "Next"}],
    description: "This tour will help you get started with Hoptopus. By the end you should know everything you need to get started using Hoptopus!",
    id: "guider-intro",
    next: "guider-dashboard",
    title: "Welcome to Hoptopus!"
  }).show();

  guiders.createGuider({
    buttons: [{name: "Next"}],
    description: "From here you can control everything about your Hoptopus account and quickly get information about what your beer collection and the beer collections of the people you're watching.",
    id: "guider-dashboard",
    next: "guider-cellar",
    title: "This is the Dashboard"
  });

  guiders.createGuider({
    attachTo: "h2[data-tab-handle]:first",
    buttons: [{name: "Next"}],
    description: "Your cellar is just your beer collection -- whether it lives in a cellar or not! Once you add all your beers to your cellar you will be able to search, filter, and sort your cellar.",
    id: "guider-cellar",
    next: 'guider-add-beer',
    position: 6,
    title: "This is your Cellar"
  });

  guiders.createGuider({
    attachTo: "div.buttons div.left:first",
    buttons: [{name: "Next"}],
    description: "You can add beers individually with the <strong>Add Beer</strong> button. If you are currently keeping track of your cellar in a spreadsheet you can import them all at once with the <strong>Import</strong> button.",
    id: "guider-add-beer",
    next: 'guider-edit-beer',
    position: 3,
    title: "Add Beer to your Cellar",
  });

  guiders.createGuider({
    attachTo: "div.buttons div.left:last",
    buttons: [{name: "Next"}],
    description: "<p>You need to select beers in your cellar to use these buttons.</p><p>Use the <strong>Edit Selected</strong> button to edit one or more beers in your cellar. You can remove one or more beers with the <strong>Remove Selected</strong> button.</p><p>If you want to file a tasting note for a beer select it in your cellar and click <strong>New Tasting Note</strong>.",
    id: 'guider-edit-beer',
    next: 'guider-watches',
    position: 6,
    width: 600,
    title: "Change the Beers in your Cellar",
  });

  guiders.createGuider({
    attachTo: "h2[data-tab-handle]:nth-child(2)",
    buttons: [{name: "Next"}],
    description: "<p>When you find another user that has a cellar that you find interesting you can <strong>Watch</strong> that cellar. Then you can find get an update in the <strong>Watched Recent Changes</strong> of your dashboard when they add, remove, or change a beer in their cellar.</strong>",
    id: 'guider-watches',
    next: 'guider-search',
    position: 6,
    width: 600,
    title: "Watch Other Users and their Cellars",
  });

  guiders.createGuider({
    attachTo: "#navigation div.search",
    buttons: [{name: "Next"}],
    description: "<p>Search for the people you know by username, first name, and last name. Once you find them, click the <strong>Watch</strong> button and you will be updated when they add, remove, or change beers in their cellar.</p>",
    id: 'guider-search',
    position: 6,
    title: "Find People You Know",
  });
});
