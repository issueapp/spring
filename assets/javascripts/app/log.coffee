# build data user
unless window.client_geo_data
  $.getJSON "http://smart-ip.net/geoip-json?callback=?", (data) ->
    window.client_geo_data = data

if not window.issue_uid or document.cookie.match("issue_uid")
  window.issue_uid = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)
  document.cookie = "issue_uid=" + issue_uid + "; expires=Fri, 31 Dec " + ((new Date()).getFullYear() + 99) + " 23:59:59 GMT; path=/"

# build environment
tracking_env = (action, title, env) ->
  env or env = {}
  client_geo_data = window.client_geo_data or {}
  user = window.App and App.user and App.user.toJSON()
  $.extend
    action: action
    page: env["page"] or $("link[rel=canonical]").attr("href") or window.location.toString()
    
    # Title: explicity set or default to document.title
    title: title or document.title
    
    # Magazine: magazine handle
    magazine: null
    
    # Issue: issue handle (short name)
    issue: null

    # Content page id
    page_id: $("[data-page-id]").attr("data-page-id")

    # Author
    author: null
    
    # User
    user: user
    
    # client device
    url: window.location.toString()
    uid: issue_uid
    referer: document.referrer
    agent: navigator.userAgent
  , env, client_geo_data

App.on "track", (action, title, data) ->
  track_url = "//127.0.0.1:9200/analytics/events"
  $.post track_url, JSON.stringify(tracking_env(action, title, data))
