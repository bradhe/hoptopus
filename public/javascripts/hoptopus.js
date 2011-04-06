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
        span.css('z-index', '1000');
        
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

        bottom = qsort(property, bottom, comp);
        top = qsort(property, top, comp);

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