# App notification
#
# Provide Native app behaviour and notification API between Web JS and Native App

# Intercept user behaviors to native app protocol
#

#
# 1. Click on links that supports App URI
#
#   data-app-uri
#
#   <a href="/login" title="Men in fresh" data-modal=true data-app-uri>Browse</a>
#   issue://open/login?modal=true
#
$(document).on "click", "[data-app-view]", ->
  options = {}

  if view = $(this).data('app-view')
    options.view = view

  if title = ($(this).attr('title') || $(this).attr('data-title')) || $(this).text()
    options.title = title

  # open modal,
  App.trigger "open", this.href, options

  return false if App.support.webview

# 2. Click on page element to notify user action


# Track actions
# 
# I think for tracking events, we need to have a global 
# App.trigger("track", "action", "title", options)
# 
# a data-track="click" title="my external page"
# a data-track="shop" title="latest shoes" href="amazon.com"
# a data-track="call" title="taylor luk" href="tel:29561079"
# a data-track="call" title="taylor luk" href="tel:29561079"

$(document).on "click", "[data-track]", (e)->
  action = $(this).data('track')
  title = $(this).attr('title') || $(this).attr('data-title') || $(this).text()

  options = {
    edition_id: $(this).data("edition-id") || $(this).parents("[data-edition-id]").data("edition-id")
    item_id: $(this).data("item-id") || $(this).parents("[data-item-id]").data("item-id")
    url: $(this).data('url') || this.href
  }
  
  # console.log '[notification.coffee]', action, title, options

  App.trigger("track", action, title, options)
  
  if App.support.webview && (App.user.id == 'guest' || ['share', 'unsubscribe', 'go:next'].indexOf(action) > -1)
    return false

  # simulate data remote
  if $(this).attr 'data-remote-action'
    $.ajax(
      url: this.href,
      script: true,
      method: $(this).data('method')
    )
    return false

