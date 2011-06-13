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

  h.showProgress = function(text, fn) {
    if(currentProgress) {
      this.hideProgress();
    }

    var progressImg = $('<img/>').attr('src', '/images/progress-black.gif');

    var span = $('<span/>').addClass('progress');
    span.append($(progressImg));
    span.append(text);
  
    var left = ($(window).width() / 2) - (span.outerWidth() / 2);
    span.css('left', left);

    span.hide();
    $('body').prepend(span);
    span.slideDown('fast');
    currentProgress = span;

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

    bottom = h.qsort(property, bottom, comp);
    top = h.qsort(property, top, comp);

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

  return h;
}(jQuery));
