# Libraries
#
#= require zepto
#= require underscore
#= require backbone
#= require fastclick

# Iframe communication
#= require postmessage
#= require mustache

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

  issue.js core layout hotspot notification page
  application.js core layout hotspot notification page ui viewer
  admin.js application, admin
  embed.js core layout hotspot notification page ui viewer

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
parent_url = decodeURIComponent(document.location.hash.replace(/^#/, ''))
parent_host = parent_url.split("/").slice(0,3).join('/');

App.notifyViewer = (method, params...)=>
  
  # Dispatched Iframe communication (MessageEvent)
  # Request { method: 'string', params: 'array', id: 'unique_id }
  # Request { result: 'object', id: 'unique_id }
  message = JSON.stringify({ method: method, params: params})
  XD.postMessage(message, parent_url, parent);


XD.receiveMessage (message) =>
  request = $.parseJSON(message.data)
  args = [null, "embed", request.method].concat( request.params )
  
  if request.method == "next-page"
    if App.pageView && App.pageView.canScroll()
      App.pageView.next()
    else
      App.notifyViewer("next")
    
    console.log("next-page", App.pageView && App.pageView.canScroll() )
    
  else if request.method == "prev-page"
    
    if  App.pageView && App.pageView.canScroll("left")
      App.pageView.prev()
    else
      App.notifyViewer("prev")    
  
  App.trigger.call(args)
  
  console.log("Embed Issue", args)
  # this[request.method]() if request.method == "close"
  
, parent_host

console.log(parent_host)


###
  Video thumbnail
###
$(document).on "click", '.video .thumbnail', -> 
  
  iframe = $(this).next().children('iframe')
  
  iframe.attr('src', iframe.data('src')).show()
  
  $(this).css('visibility', 'hidden')
  $(this).parent().css('zoom', 1)
  

window.addEventListener 'load', ->

  FastClick.attach(document.body)

  
, false
