(function($) {
  function PagedDialog(elem, options) {
    // Create a local copy of the elem to prevent crappy memory issues.
    var elem = elem;

    var settings = {
      pageSelector: null,
      pageChanged: null,
      dialogOptions: null
    };

    if(options) {
      $.extend(settings, options);
    }

    d = {};
    var pages = [];
    var currentPage = -1;
    var pageButtons = null;

    function showPageByNumber(pageNumber) {
      // Do some bounds checking too, make sure we're not doing anything funky.
      if(pageNumber < 0) {
        throw "Page number must be greater than or equal to 0.";
      }
      else if(pageNumber >= pages.length) {
        throw "Cannot navigate to page " + pageNumber + ". Number of pages in collection: " + pages.length;
      }

      $(pages[currentPage]).hide();

      // Remove the currently selected.
      $(d.links[currentPage]).removeClass('selected');
      currentPage = pageNumber;

      // Change current page.
      $(d.links[currentPage]).addClass('selected');
      $(pages[currentPage]).show();

      // If the current page is now the last page or the first page disable the prev or next button.
      if(d.prevButton && currentPage == 0) {
        d.prevButton.hide();
      }
      else if(d.prevButton && d.prevButton.is(':hidden')) {
        d.prevButton.show();
      }

      if(d.nextButton && currentPage >= pages.length-1) {
        d.nextButton.hide();
      }
      else if(d.nextButton && d.nextButton.is(':hidden')) {
        d.nextButton.show();
      }

      if($.isFunction(settings.pageChanged)) {
        settings.pageChanged();
      }
    }

    function init() {       
      if(settings.pageSelector) {
        pages = $(elem).find(settings.pageSelector);
      }

      // If there are still no pages then we have a fucking problem.
      if(pages.length < 1) {
        throw "No pages found with selector " + elem;
      }

      var div = $('<div/>').addClass('ui-paged-dialog');
      div.append(elem);

      // We need to create page buttons for all this.
      pageButtons = $('<div/>').addClass('pages');
      pageNumbers = $('<span/>').addClass('page-numbers');
      prevSpan = $('<span/>').addClass('prev');
      nextSpan = $('<span/>').addClass('next');

      // Save for later
      settings.pageNumbers = pageNumbers;

      pageButtons.append(prevSpan);
      pageButtons.append(pageNumbers);
      pageButtons.append(nextSpan);

      // Highlight the first one.
      div.append(pageButtons);

      // We need to add NEXT and PREV buttons as well.
      var nextLink = $('<a/>').attr('href', 'javascript:void(0);').html('Next &raquo;');
      var prevLink = $('<a/>').attr('href', 'javascript:void(0);').html('&laquo; Prev');
      nextLink.click(function(e) { return d.onNextClicked(e) });
      prevLink.click(function(e) { return d.onPrevClicked(e) });

      // By default the previous button should be hidden.
      prevLink.hide();

      prevSpan.prepend(prevLink);
      nextSpan.append(nextLink);

      // Save this crap for later.
      d.nextButton = nextLink;
      d.prevButton = prevLink;

      d.dialog = div;

      // Finally, rebuild the links for the pages.
      d.rebuildLinks(pages, pageNumbers);

      // Show the dialog now.
      $(div).dialog(settings.dialogOptions);
    }

    d.onNextClicked = function(e) {
      showPageByNumber(currentPage + 1);
    };

    d.onPrevClicked = function(e) {
      showPageByNumber(currentPage - 1);
    };

    d.onPageNumberClicked = function(e, pageNumber) {
      if(pageNumber != currentPage) {
        showPageByNumber(pageNumber);
      }

      return false;
    };

    d.close = function() {
      $(d.dialog).dialog('close');
    };

    d.rebuildLinks = function(newPages, container) {
      container = container || settings.pageNumbers;

      if(newPages) {
        pages = newPages;
      }
      else {
        throw "You need to tell me what pages to use to build these links!"
      }

      if(d.links) {
        // Remove the current links since there are some defined.
        var l = d.links.length;

        for(var i = 0; i < l; i++) {
          $(d.links[i]).remove();
        }
      }

      d.links = [];
      currentPage = 0;

      // Okay, we want to remove everything from the elem except the first page.
      var hidden = pages.slice(1);
      var l = hidden.length;

      for(var i = 0; i < l; i++) {
        $(hidden[i]).hide();
      }

      for(var i = 0; i < pages.length; i++) {
        var a = $('<a/>').text(i+1).attr('href', 'javascript:void(0);').data('page_number', i);
        a.click(function(e) { return d.onPageNumberClicked(e, $(this).data('page_number')); });

        $(container).append(a);
        d.links.push(a);
      }

      $(d.links[0]).addClass('selected');
      showPageByNumber(0);
    };
    
    init();

    return d;
  }
  
  $.fn.pagedDialog = function(options) {
    var dialogs = [];
    
    this.each(function(i) {
      dialogs.push(new PagedDialog(this, options));
    });
    
    return dialogs;
  };
}(jQuery));
