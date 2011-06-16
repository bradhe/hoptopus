/**
 * Created by .
 * User: brad.heller
 * Date: 3/21/11
 * Time: 12:14 AM
 * To change this template use File | Settings | File Templates.
*/
var hoptopus = (function($) {
  var h = {};
  var currentProgress = null;

  h.showAlert = function(text, timeout) {
    var span = $('<span/>').addClass('alert');
    span.text(text);

    span.hide();
    $('body').prepend(span);
    span.slideDown('fast');

    window.setTimeout(function() {
      span.slideUp('fast', function() {
        $(this).remove();
      });
    }, timeout || 3000);
  };

  h.showProgress = function(text, fn) {
    if(currentProgress) {
      this.hideProgress();
    }

    var progressImg = $('<img/>').attr('src', '/images/progress-black.gif');

    var span = $('<span/>').addClass('progress');
    span.append($(progressImg));

    var textSpan = $('<span/>');

    if($.isArray(text)) {
      textSpan.append(text[0]);
    }
    else {
      textSpan.append(text);
    }

    span.append(textSpan);

    span.hide();
    $('body').prepend(span);
    span.slideDown('fast');
    currentProgress = span;

    // Every few 3 seconds, rotate the text if it's an array.
    if($.isArray(text)) {
      var i = 1; // We already displayed the first one.
      var t = window.setTimeout(function() {
        if(i < text.length) {
          textSpan.text(text[i++]);
        }
        else {
          // Should cancel itself.
          window.clearTimeout(t);
        }
      }, 2000);
    }

    if(fn) {
      fn();
    }
  };

  h.hideProgress = function() {
    if(currentProgress != null) {
      currentProgress .slideUp('fast', function() {
        $(this).remove();
        currentProgress = null;
      });
    }
  };

  h.clientData = {};
  h.data = function(name, data) {
    if(data) {
      h.clientData[name] = data;
      return data;
    }
    else {
      return h.clientData[name];
    }
  };

  h.load = function(scriptPath, options) {
    var settings = {
      async: true,
      complete: null,
      started: null
    };

    if(options) {
      $.extend(settings, options);
    }

    var script = document.createElement('script');

    // TODO: Determine if this is even safe...
    var head = document.getElementsByTagName('head')[0];

    script.src = scriptPath;
    script.type = 'text/javascript';
    script.async = settings.async;

    if(settings.complete) {
      script.onload = settings.complete;
    }

    if(settings.started) {
      // Do that callback
      settings.started();
    }

    head.appendChild(script);
  }


  h.qsort = function(property, objs, comp) {
    if(!jQuery.isArray(objs)) {
      throw "Somehow you screwed up. Objs is not an array.";
    }

    if(objs.length < 2) {
      return objs;
    }

    // Set a random pivot.
    var p = objs[0];
    var top = [];
    var bottom = [];

    for(var i = 1; i < objs.length; i++) {
      var o = objs[i];
      var c = comp(p[property], o[property]);
      if(c) {
        bottom.push(o);
      }
      else {
        top.push(o);
      }
    }

    bottom = hoptopus.qsort(property, bottom, comp);
    top = hoptopus.qsort(property, top, comp);

    var t = [];
    for(var i = 0; i < bottom.length; i++) {
      t.push(bottom[i]);
    }

    t.push(p);

    for(var i = 0; i < top.length; i++) {
      t.push(top[i]);
    }

    return t;
  };

  // Preload the star images for ratables
  var starImg = new Image();
  starImg.src = '/images/star.png';

  var emptyStarImg = new Image();
  emptyStarImg.src = '/images/star_empty.png';

  h.initJavascriptControls = function(selector) {
    $('.star-rating').each(function() {
      var input = $(this).children('input');

      $(this).children('a[data-val]').each(function() {
        var img = $(emptyStarImg).clone();

        $(this).empty();
        $(this).append(img);

        $(this).click(function() {
          input.val($(this).attr('data-val'));

          // Set all of the stars next to this to empty and all
          // of the stars before this to show
          var next = $(this).next('a');
          while(next.length > 0) {
            var img = next.children('img');
            img.attr('src', '/images/star_empty.png');

            next = next.next('a');
          }

          var prev = $(this);
          while(prev.length > 0) {
            var img = prev.children('img');
            img.attr('src', '/images/star.png');

            prev = prev.prev('a');
          }
        });
      });
    });

    $('input.date').datepicker({
      dateFormat: 'yy-mm-dd',
      showButtonPanel: true,
      buttonImage: "/images/calendar.png",
      buttonImageOnly: false,
      changeYear: true,
      changeMonth: true
    }).each(function() {
      if(!$(this).data('has_img')) {
        var img = $('<img/>').attr('src', '/images/calendar.png').addClass('datepicker');
        $(this).after(img);
        $(this).data('has_img', true);
      }
    });
  };

  return h;
}(jQuery));
