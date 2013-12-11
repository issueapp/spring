(function() {
  this.App = {
    isDev: location.host.match(/localhost|\.dev$/),
    host: location.host.match(/localhost|\.dev$/) ? "issue.dev" : "issueapp.com",
    $: function(selector) {
      return document.querySelectorAll(selector);
    },
    isLoading: false,
    init: function() {
      this.container = $('[role=main]');
      this.setupStream();
      this.refresh();
      if (this.streamContainer.length > 0) {
        this.renderVisiblePages();
        this.renderVisibleImages();
      }
      App.content || (App.content = new ContentView);
      this.bindObservers();
      return this.trigger("loaded", encodeURIComponent(document.title), {
        url: window.location.toString(),
        handle: $('body').data('item-handle')
      });
    },
    bindObservers: function() {
      var _this = this;
      if (this.support.webview) {
        this.on("all", function(event, label, data) {
          if (_this.nativeEvents.indexOf(event) > -1) {
            return _this.notifyNative("notify", event, label, data);
          } else if (event === "open") {
            return _this.notifyNative("open", label, data);
          }
        });
      }
      $(window).on("orientationchange", function(e) {
        return _this.refresh();
      });
      document.addEventListener("page:fetch", function() {
        return _this.loading(true);
      });
      document.addEventListener("page:receive", function() {
        _this.loading(false);
        return $('[role=main]').animate({
          opacity: 1,
          duration: 150
        });
      });
      return document.addEventListener('page:change', function() {
        var url, views;
        $('[role=main]').animate({
          opacity: 1,
          duration: 150
        });
        _this.loading(false);
        if ($('.stream-paging').length > 0) {
          if (App.streamContainer && App.streamContainer.length === 0) {
            App.setupStream();
          } else {
            App.streamContainer = $('.stream-paging');
          }
          _this.refresh();
          App.detectImageSizes();
          App.renderVisiblePages();
          App.renderVisibleImages();
          if (App.content) {
            return App.content = null;
          }
        } else {
          App.streamContainer = null;
          views = 1;
          url = null;
          if (App.content) {
            views = App.content.views;
            url = App.content.url;
          }
          App.content = new ContentView({
            views: views,
            url: url
          });
          return _this.refresh();
        }
      });
    },
    loading: function(active) {
      var enabled, opts, target;
      if (this.support.webview) {
        return;
      }
      enabled = $('.stream-paging').attr('data-load-indicator');
      if (enabled === "false") {
        active = false;
      }
      this.isLoading = active;
      target = $('#loading-indicator');
      opts = {
        lines: 9,
        length: 0,
        width: 5,
        radius: 8,
        corners: 1,
        rotate: 0,
        direction: 1,
        color: "#000",
        speed: 0.7,
        trail: 70,
        shadow: false,
        hwaccel: false,
        zIndex: 2e9,
        top: "auto",
        left: "auto"
      };
      this.spinner || (this.spinner = new Spinner(opts));
      if (active) {
        return this.spinner.spin(target[0]);
      } else {
        return this.spinner.stop();
      }
    },
    extend: function(mixin) {
      return _.extend(this, mixin);
    },
    thumb_url: function(url, options) {
      var command, h, height, matches, path, size, w, width, widths;
      widths = [320, 480, 768, 1024];
      size = options.size || ("" + ($.cookie('resolution')) + "x>");
      matches = size.match(/(\d*)x(\d*)(.*)/);
      w = matches[1];
      h = matches[2];
      command = matches[3];
      width = _.find(widths, function(width) {
        return w < width;
      }) || widths[-1];
      if (h.length > 0) {
        height = Math.floor(width * h / w);
      }
      path = ['src', encodeURIComponent(url), 'thumb', encodeURIComponent("" + width + "x" + height + command), 'format', 'jpeg', 'interlace', 'true'].join('/');
      return "http://thumb.issue.by/q/" + path;
    }
  };

}).call(this);
