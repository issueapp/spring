# App core
#
# provide initialisation, support, events, native notification
#
# Requires Underscore, Bacbone, Zapto
#
# Core Methods
#
#   init:       initialise the app
#   refresh:    refresh the current application state on layout changes
#   extend:     extend additional functionalities
#   trigger:    trigger events (via Backbone.events)
#   on:

@App = {
  isDev: location.host.match /localhost|\.dev$/

  host: if location.host.match /localhost|\.dev$/ then "issue.dev" else "issueapp.com"

  #
  init: ->
    @container = $('[role=main]')

    this.refresh()
    this.bindObservers()
    this.updateLayout()
    
    this.trigger("loaded", document.title, url: window.location.toString())

  # Main
  refresh: ->

  bindObservers: ->
    if @support.webview
      this.on "all", (event, label, data)=>
        if @nativeEvents.indexOf(event) > -1
          # console.log '[issue.coffee] notify', event, label, data
          this.notifyNative("notify", event, label, data)
        else if event == "open"
          # console.log '[issue.coffee] open', label, data
          this.notifyNative("open", label, data)

  # Utilities
  extend: (mixin)->
    _.extend(this, mixin)

}

# Events
# Mixin backbone events api

#   loaded - domready and app core is loaded
#
#   page:change
#   page:fetch
#   page:receive
#   page:load
#
#   stream:swipe
#   stream:change
#   stream:scroll-start
#   stream:scroll-end
#
# Examples:
#
#  App.on "page:swipe", (arg1, arg2)-> alert("page swiped")
#
#  App.trigger("loaded")
#  App.trigger("page:swipe", { })
#  App.trigger("page:swipe", { })
#
# Exends Backbone events
#
#   App.on("loaded", funcion() { alert("app loaded" )})
#   App.trigger("loaded")
#
App.extend Backbone.Events

Core = {
  # Support & feature detection
  support: {
    
    embed: !!document.location.href.match(/\/embed\//),

    standalone: !!window.navigator.standalone

    touch: document.documentElement.hasOwnProperty("ontouchstart")

    orientation: window.hasOwnProperty("orientation")

    webview: !!document.cookie.match(/\bwebview\b/) || !!/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(navigator.userAgent)

    swipe: !!navigator.userAgent.match(/iPad/)

    swipeUp: !!navigator.userAgent.match(/(iPhone|iPod)/) && window.screen.height <= 568
  }

  # Notify JS => Native App
  #
  # Send event notification to native app envionrment via app URI
  #  issue://method/param1/param2?option=1
  #
  nativeEvents: [
    "go:next", "loaded", "stream:change", "subscribe", "unsubscribe", "share", "click", "purchase", "hide:nav", "head_ready"
  ]

  # Example
  #
  #   issue://notify/page:change?
  #   issue://track/view/Page+1?url=http://issue.by&edition_id=1   (event, label, data)
  #   issue://open/http%3A%2F%2Fissue.by
  #
  #   App.on("stream:change page:change", function(e) {
  #     App.notifyNative("event", "stream:change"); console.log(e)
  #   })
  #
  # If iframe request and protocol matches issue://, also matches support methods [event, track, open]
  #
  notifyNative: ->
    paths = []
    params = {}

    _(arguments).each (argument)->
      paths.push argument if _.isString(argument)
      params = argument  if argument && !_.isString(argument) && _.isObject(argument) && !_.isElement(argument)

    url = "issue://#{_(paths).map(encodeURIComponent).join("/")}"

    if _(params).size() > 0
      url += "?#{$.param(params)}"

    console.log("[Notify] #{url}")

    iframe = document.createElement("IFRAME")
    iframe.setAttribute("src", url)
    # Break current ui thread

    setTimeout =>
      document.documentElement.appendChild(iframe)
      iframe.parentNode.removeChild(iframe)
      iframe = null
    , 0
}
App.extend Core

