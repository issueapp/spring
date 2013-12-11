(function() {
  var Core;

  App.extend(Backbone.Events);

  Core = {
    support: {
      standalone: !!window.navigator.standalone,
      touch: document.documentElement.hasOwnProperty("ontouchstart"),
      orientation: window.hasOwnProperty("orientation"),
      webview: true || !!document.cookie.match(/\bwebview\b/) || !!/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(navigator.userAgent),
      swipe: !!navigator.userAgent.match(/iPad/),
      swipeUp: !!navigator.userAgent.match(/(iPhone|iPod)/)
    },
    nativeEvents: ["go:next", "loaded", "stream:change", "subscribe", "unsubscribe", "share", "click", "purchase", "hide:nav", "head_ready"],
    notifyNative: function() {
      var iframe, params, paths, url,
        _this = this;
      paths = [];
      params = {};
      _(arguments).each(function(argument) {
        if (_.isString(argument)) {
          paths.push(argument);
        }
        if (argument && !_.isString(argument) && _.isObject(argument) && !_.isElement(argument)) {
          return params = argument;
        }
      });
      url = "issue://" + (_(paths).map(encodeURIComponent).join("/"));
      if (_(params).size() > 0) {
        url += "?" + ($.param(params));
      }
      console.log("[Notify] " + url);
      iframe = document.createElement("IFRAME");
      iframe.setAttribute("src", url);
      return setTimeout(function() {
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        return iframe = null;
      }, 0);
    }
  };

  App.extend(Core);

}).call(this);
