(function() {
  $(document).on("click", "[data-app-view]", function() {
    var options, title, view;
    options = {};
    if (view = $(this).data('app-view')) {
      options.view = view;
    }
    if (title = ($(this).attr('title') || $(this).attr('data-title')) || $(this).text()) {
      options.title = title;
    }
    App.trigger("open", this.href, options);
    if (App.support.webview) {
      return false;
    }
  });

  $(document).on("click", "[data-action]", function(e) {
    var action, options, title;
    action = $(this).data('action');
    title = $(this).attr('title') || $(this).attr('data-title') || $(this).text();
    options = {
      edition_id: $(this).data("edition-id") || $(this).parents("[data-edition-id]").data("edition-id"),
      item_id: $(this).data("item-id") || $(this).parents("[data-item-id]").data("item-id"),
      url: $(this).data('url') || this.href
    };
    App.trigger(action, title, options);
    if (App.support.webview && (App.user.id === 'guest' || ['share', 'unsubscribe', 'go:next'].indexOf(action) > -1)) {
      return false;
    }
    if ($(this).attr('data-remote-action')) {
      $.ajax({
        url: this.href,
        script: true,
        method: $(this).data('method')
      });
      return false;
    }
  });

}).call(this);
