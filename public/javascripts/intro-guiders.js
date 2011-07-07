$(function() {
  guiders.createGuider({
    buttons: [{name: "Thanks but no thanks."}, {name: "Next"}],
    description: "This tour will help you get acquainted with Hoptopus and how it works.",
    id: "first",
    next: "second",
    overlay: true,
    title: "Welcome to Hoptopus!"
  }).show();

  guiders.createGuider({
    attachTo: "div.buttons div.left:first",
    buttons: [{name: "Next"}],
    description: "You can add beers and remove beers.",
    id: "second",
    next: 'third',
    position: 3,
    title: "Step 1. Add Beer to your Cellar",
    width: 450
  });

  guiders.createGuider({
    attachTo: "#navigation div.search",
    buttons: [{name: "Next"}],
    description: "Share your beers with others.",
    id: 'third',
    position: 6,
    title: "Step 2. Find Peopl you Know",
    width: 450
  });
});
