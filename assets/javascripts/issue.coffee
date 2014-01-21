# Libraries
# 
#= require zepto
#= require underscore
#= require backbone
#= require fastclick

#= require mustache

#= require spring.ui
#= require app/core
#= require app/layout
#= require app/hotspot
#= require app/notification
#= require app/page

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



window.addEventListener 'load', ->
  FastClick.attach(document.body)
  
, false
  