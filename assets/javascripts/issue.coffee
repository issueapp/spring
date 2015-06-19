# Libraries
#
#= require zepto
#= require underscore
#= require backbone
#= require mustache

# Patches/Polyfills
#= require fastclick

#= require spring.ui
#= require app/core
#= require app/layout
#= require app/hotspot
#= require app/notification
#= require app/page
#= require app/log

#= require app/models
#= require app/magazine


###

  issue.js

  contains only the essential libraries and core app module

  Scenario:

    stream -> page
    issue  -> page

  issue.js        core layout hotspot notification page
  application.js  core layout hotspot notification page ui viewer
  admin.js        application, admin
  embed.js        core layout hotspot notification page ui viewer

  Clients:

    native webview: embeded in native app using native UI
      issue  -> page

    browser view: Web based UI implemented in CSS
      app/ui (menu, navbar, issue menu)

    iframe embed:
      app/ui
      app/viewer

###


###

  Embed viewer

###




if App.support.embed
  request = document.createElement('a')

  if matches = document.location.search.match(/from=([^&]+)/)
    request.href = decodeURIComponent(matches[1])

  App.embed_url = request.href

App.notifyViewer = (method, params...)=>

  # Dispatched Iframe communication (MessageEvent)
  # Request { method: 'string', params: 'array', id: 'unique_id }
  # Request { result: 'object', id: 'unique_id }
  message = JSON.stringify({ method: method, params: params})

  console.log("Notify viewer", message)
  XD.postMessage(message, request.href, parent);

window.addEventListener 'message', (event)->
  console.log(event.domain, event.data)

  event = $.parseJSON(event.data)
  args = [null, "embed", event.method].concat( event.params )

  if event.method == "next-page"
    if App.pageView && App.pageView.canScroll()
      App.pageView.next()
    else
      App.notifyViewer("next")

  else if event.method == "prev-page"

    if  App.pageView && App.pageView.canScroll("left")
      App.pageView.prev()
    else

      App.notifyViewer("prev")
      # parent.Viewer.prev()  if request.host == parent.location.host

  App.trigger.call(args)

  console.log("Embed Issue", args)

window.addEventListener 'load', ->

  FastClick.attach(document.body)


, false
