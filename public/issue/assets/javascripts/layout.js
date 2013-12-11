(function() {
  var Layout;

  Layout = {
    container: null,
    orientation: null,
    landscape: null,
    portrait: null,
    pageSize: {
      height: 0,
      width: 0
    },
    viewport: {
      height: 0,
      width: 0
    },
    refresh: function() {
      var offsetX, offsetY, page, pages, previous;
      previous = {
        height: this.viewport.height,
        width: this.viewport.width
      };
      this.detectLayout();
      this.updateLayout();
      this.changeOrientation();
      this.detectImageSizes();
      page = $('.stream.page:not(.template)');
      this.pageSize = {
        height: page.height(),
        width: page.width()
      };
      this.updatePadding();
      this.updateContentWidth();
      if (this.support.swipe === "horizontal") {
        offsetX = this.scrollTarget[0].scrollLeft || this.scrollTarget[0].scrollX;
        pages = offsetX / previous.width;
        if (offsetX > 0) {
          return this.scrollTarget[0].scrollTo(pages * this.viewport.width, 0);
        }
      } else {
        offsetY = this.scrollTarget[0].scrollTop || this.scrollTarget[0].scrollY;
        pages = offsetY / previous.height;
        if (offsetY > 0) {
          return this.scrollTarget[0].scrollTo(0, pages * this.viewport.height);
        }
      }
    },
    detectLayout: function() {
      if (navigator.userAgent.match(/(iPhone|iPod)/)) {
        this.support.swipe = "vertical";
      } else if (!!navigator.userAgent.match(/iPad/)) {
        this.support.swipe = "horizontal";
      }
      if (this.support.swipe && !this.support.webview) {
        window.scrollTo(0, 1);
      }
      if (this.support.swipe === "horizontal") {
        $('[role=main]').addClass("horizontal");
      } else {
        $('[role=main]').addClass("vertical");
      }
      if (window.orientation) {
        this.orientation = window.orientation % 180 === 0 ? 'portrait' : 'landscape';
      } else {
        this.orientation = "portrait";
      }
      this.landscape = this.orientation === "landscape";
      this.portraite = this.orientation === "portrait";
      if (this.support.swipe) {
        this.viewport.width = Math.max(320, window.innerWidth);
        return this.viewport.height = window.innerHeight;
      } else {
        this.viewport.width = Math.min(1024, window.innerWidth);
        return this.viewport.height = Math.min(704, window.innerHeight);
      }
    },
    updateLayout: function() {
      var css, style;
      if (this.support.swipe) {
        css = "        #sections { max-width: " + this.viewport.width + "px }\n        article.two-column.paginate .body { width: " + this.viewport.width + "px }\n        article.two-column .top-image { width: " + (this.viewport.width / 2) + "px }\n        [role=main] .page {\n          width: " + this.viewport.width + "px;          height: " + this.viewport.height + "px;        }\n      ";
      } else {
        css = "        article.two-column .top-image { width: " + (this.viewport.width / 2) + "px }\n        article.two-column.paginate .body { width: " + this.viewport.width + "px }\n        \n        [role=main] .page {          height: " + this.viewport.height + "px;          width: 100%;        }\n      ";
      }
      style = document.createElement('style');
      style.type = 'text/css';
      style.id = "touch-layout";
      if (style.styleSheet) {
        style.styleSheet.cssText = css;
      } else {
        style.appendChild(document.createTextNode(css));
      }
      $('#touch-layout').remove();
      return $(document.head).append(style);
    },
    changeOrientation: function(new_pages) {
      var className, from, mapping, orientation, pages, switchLandscape, toClass, _ref;
      pages = new_pages || $('.stream.page');
      if (window.orientation % 180 === 0 || this.support.swipe === "vertical") {
        orientation = 'vertical';
      } else {
        orientation = 'horizontal';
      }
      from = pages.data('orientation') || this.support.swipe;
      if (from === orientation) {
        return;
      } else {
        switchLandscape = orientation === 'horizontal';
      }
      mapping = {
        "row v-half": "col half",
        "item third": "item v-third",
        "item half": "item v-half",
        "item third-2": "item v-third-2",
        "item split": "item no-split"
      };
      for (className in mapping) {
        toClass = mapping[className];
        if (switchLandscape) {
          _ref = [toClass, className], className = _ref[0], toClass = _ref[1];
        }
        pages.find("." + (className.split(" ").join("."))).removeClass(className).addClass(toClass);
      }
      pages.data('orientation', orientation);
      return pages;
    },
    detectImageSizes: function() {
      var height, template, width, _ref;
      if (this.imageSizes == null) {
        this.imageSizes = {};
      }
      template = $('.page.template');
      if (this.landscape) {
        width = screen.width;
        height = screen.height;
        if (height > width) {
          _ref = [height, width], width = _ref[0], height = _ref[1];
        }
      } else {
        width = window.innerWidth;
        height = window.innerHeight;
      }
      template.show();
      template.find('.item .image').each(function() {
        var size_class;
        size_class = $.trim(this.parentNode.className.replace('item photo', ''));
        return App.imageSizes[size_class] = {
          width: $(this).width(),
          height: $(this).height()
        };
      });
      return template.hide();
    },
    updateContentWidth: function() {
      var content_overflow, two_col_page,
        _this = this;
      two_col_page = $('.two-column').removeClass('paginate');
      if (two_col_page.length > 0) {
        if (content_overflow = two_col_page[0].scrollHeight > (two_col_page[0].offsetHeight + 20)) {
          two_col_page.css('width', '');
          if (content_overflow) {
            two_col_page.addClass('paginate');
          }
          return setTimeout(function() {
            var width;
            width = Math.ceil(two_col_page[0].scrollWidth / App.viewport.width) * App.viewport.width;
            return two_col_page.width(width);
          }, 200);
        }
      }
    },
    scrollTop: function(element, duration) {
      var animloop, scrollTop;
      if (duration == null) {
        duration = 200;
      }
      element = $(element)[0] || window;
      scrollTop = $(element).scrollTop();
      if (!scrollTop) {
        return;
      }
      return (animloop = function() {
        var step;
        if (scrollTop > 0) {
          step = (scrollTop / 200) * 16;
          if (step < 50) {
            step = 50;
          }
          scrollTop = scrollTop - step;
          if (scrollTop < 0) {
            scrollTop = 0;
          }
          element.scrollTop = scrollTop;
          return requestAnimationFrame(animloop);
        } else {
          return element.scrollTop = 0;
        }
      })();
    },
    overlay: function(toggle) {
      if (toggle === false) {
        $('.overlay')["false"]();
        return $(document.body).toggleClass('locked', false);
      } else {
        $('.overlay').show();
        return $(document.body).toggleClass('locked', true);
      }
    }
  };

  App.extend(Layout);

}).call(this);
