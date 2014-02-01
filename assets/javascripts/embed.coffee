# Post Messages
`var XD=function(){var e,t,n=1,r,i=this;return{postMessage:function(e,t,r){if(!t){return}r=r||parent;if(i["postMessage"]){r["postMessage"](e,t.replace(/([^:]+:\/\/[^\/]+).*/,"$1"))}else if(t){r.location=t.replace(/#.*$/,"")+"#"+ +(new Date)+n++ +"&"+e}},receiveMessage:function(n,s){if(i["postMessage"]){if(n){r=function(e){if(typeof s==="string"&&e.origin!==s||Object.prototype.toString.call(s)==="[object Function]"&&s(e.origin)===!1){return!1}n(e)}}if(i["addEventListener"]){i[n?"addEventListener":"removeEventListener"]("message",r,!1)}else{i[n?"attachEvent":"detachEvent"]("onmessage",r)}}else{e&&clearInterval(e);e=null;if(n){e=setInterval(function(){var e=document.location.hash,r=/^#?\d+&/;if(e!==t&&r.test(e)){t=e;n({data:e.replace(r,"")})}},100)}}}}}()`

# Mousetrap.js
`(function(e,t,n){function m(e,t,n){if(e.addEventListener){e.addEventListener(t,n,false);return}e.attachEvent("on"+t,n)}function g(e){if(e.type=="keypress"){var t=String.fromCharCode(e.which);if(!e.shiftKey){t=t.toLowerCase()}return t}if(r[e.which]){return r[e.which]}if(i[e.which]){return i[e.which]}return String.fromCharCode(e.which).toLowerCase()}function y(e,t){return e.sort().join(",")===t.sort().join(",")}function b(e){e=e||{};var t=false,n;for(n in l){if(e[n]){t=true;continue}l[n]=0}if(!t){d=false}}function w(e,t,n,r,i,s){var o,u,f=[],c=n.type;if(!a[e]){return[]}if(c=="keyup"&&k(e)){t=[e]}for(o=0;o<a[e].length;++o){u=a[e][o];if(!r&&u.seq&&l[u.seq]!=u.level){continue}if(c!=u.action){continue}if(c=="keypress"&&!n.metaKey&&!n.ctrlKey||y(t,u.modifiers)){var h=!r&&u.combo==i;var p=r&&u.seq==r&&u.level==s;if(h||p){a[e].splice(o,1)}f.push(u)}}return f}function E(e){var t=[];if(e.shiftKey){t.push("shift")}if(e.altKey){t.push("alt")}if(e.ctrlKey){t.push("ctrl")}if(e.metaKey){t.push("meta")}return t}function S(e){if(e.preventDefault){e.preventDefault();return}e.returnValue=false}function x(e){if(e.stopPropagation){e.stopPropagation();return}e.cancelBubble=true}function T(e,t,n,r){if(B.stopCallback(t,t.target||t.srcElement,n,r)){return}if(e(t,n)===false){S(t);x(t)}}function N(e,t,n){var r=w(e,t,n),i,s={},o=0,u=false;for(i=0;i<r.length;++i){if(r[i].seq){o=Math.max(o,r[i].level)}}for(i=0;i<r.length;++i){if(r[i].seq){if(r[i].level!=o){continue}u=true;s[r[i].seq]=1;T(r[i].callback,n,r[i].combo,r[i].seq);continue}if(!u){T(r[i].callback,n,r[i].combo)}}var a=n.type=="keypress"&&p;if(n.type==d&&!k(e)&&!a){b(s)}p=u&&n.type=="keydown"}function C(e){if(typeof e.which!=="number"){e.which=e.keyCode}var t=g(e);if(!t){return}if(e.type=="keyup"&&h===t){h=false;return}B.handleKey(t,E(e),e)}function k(e){return e=="shift"||e=="ctrl"||e=="alt"||e=="meta"}function L(){clearTimeout(c);c=setTimeout(b,1e3)}function A(){if(!u){u={};for(var e in r){if(e>95&&e<112){continue}if(r.hasOwnProperty(e)){u[r[e]]=e}}}return u}function O(e,t,n){if(!n){n=A()[e]?"keydown":"keypress"}if(n=="keypress"&&t.length){n="keydown"}return n}function M(e,t,n,r){function i(t){return function(){d=t;++l[e];L()}}function s(t){T(n,t,e);if(r!=="keyup"){h=g(t)}setTimeout(b,10)}l[e]=0;for(var o=0;o<t.length;++o){var u=o+1===t.length;var a=u?s:i(r||D(t[o+1]).action);P(t[o],a,r,e,o)}}function _(e){if(e==="+"){return["+"]}return e.split("+")}function D(e,t){var n,r,i,u=[];n=_(e);for(i=0;i<n.length;++i){r=n[i];if(o[r]){r=o[r]}if(t&&t!="keypress"&&s[r]){r=s[r];u.push("shift")}if(k(r)){u.push(r)}}t=O(r,u,t);return{key:r,modifiers:u,action:t}}function P(e,t,n,r,i){f[e+":"+n]=t;e=e.replace(/\s+/g," ");var s=e.split(" "),o;if(s.length>1){M(e,s,t,n);return}o=D(e,n);a[o.key]=a[o.key]||[];w(o.key,o.modifiers,{type:o.action},r,e,i);a[o.key][r?"unshift":"push"]({callback:t,modifiers:o.modifiers,action:o.action,seq:r,level:i,combo:e})}function H(e,t,n){for(var r=0;r<e.length;++r){P(e[r],t,n)}}var r={8:"backspace",9:"tab",13:"enter",16:"shift",17:"ctrl",18:"alt",20:"capslock",27:"esc",32:"space",33:"pageup",34:"pagedown",35:"end",36:"home",37:"left",38:"up",39:"right",40:"down",45:"ins",46:"del",91:"meta",93:"meta",224:"meta"},i={106:"*",107:"+",109:"-",110:".",111:"/",186:";",187:"=",188:",",189:"-",190:".",191:"/",192:"\`",219:"[",220:"\\",221:"]",222:"'"},s={"~":"\`","!":"1","@":"2","#":"3",$:"4","%":"5","^":"6","&":"7","*":"8","(":"9",")":"0",_:"-","+":"=",":":";",'"':"'","<":",",">":".","?":"/","|":"\\"},o={option:"alt",command:"meta","return":"enter",escape:"esc",mod:/Mac|iPod|iPhone|iPad/.test(navigator.platform)?"meta":"ctrl"},u,a={},f={},l={},c,h=false,p=false,d=false;for(var v=1;v<20;++v){r[111+v]="f"+v}for(v=0;v<=9;++v){r[v+96]=v}m(t,"keypress",C);m(t,"keydown",C);m(t,"keyup",C);var B={bind:function(e,t,n){e=e instanceof Array?e:[e];H(e,t,n);return this},unbind:function(e,t){return B.bind(e,function(){},t)},trigger:function(e,t){if(f[e+":"+t]){f[e+":"+t]({},e)}return this},reset:function(){a={};f={};return this},stopCallback:function(e,t){if((" "+t.className+" ").indexOf(" mousetrap ")>-1){return false}return t.tagName=="INPUT"||t.tagName=="SELECT"||t.tagName=="TEXTAREA"||t.isContentEditable},handleKey:N};e.Mousetrap=B;if(typeof define==="function"&&define.amd){define(B)}})(window,document)`


#@App = {}

unless jQuery? || Zepto?
  return alert("Error: Jquery or Zepto is required")

##
# Detect magazine and issue params
#
file = (script.src for script in document.getElementsByTagName('script') when script.src.match(/embed\.js/))

request = document.createElement('a')
request.href = file[0]

if matches = request.search.match(/magazine=([^&]+)/)
  magazine = matches[1]
else
  alert("Error: Require a valid magazine params ")

if matches = request.search.match(/issue=([^&]+)/)
  issue = matches[1]
else
  issue = null

# Base url
if request.host.match(/\.dev/)
  base_url =  "http://spring.dev/"
else
  base_url = "http://issue.by/embed/"

issue_url = base_url + "#{magazine}/#{issue}/"

#
#  Issue viewer
#
Viewer =

  # http://localhost:3000/issue
  # file:///var/a/b/d/issue
  path: null

  init: (url) ->
    @url = url

    @container = $("#issue-viewer").css({'background': "#fff"})
    @container = document.body if @container.length == 0

    parts = url.split('/')
    # parts.pop()  if parts.length > 5
    @path = parts.join("/")

    console.log("Init viewer", @path)

    # Build iframe
    @frame = this.buildIframe()
    
    this.goTo('index')
    
    # Load pages and menu
    $.getJSON issue_url + 'issue.json?callback=?', (data)->
      Viewer.load(data)

    # Set current page
    this.setCurrentPage( this.currentPage() )

    @nextBtn = $('<a class="next-page" href="#">›</a>')
    @prevBtn = $('<a class="prev-page" href="#">‹</a>')
    @container.prepend(@nextBtn).prepend(@prevBtn)

    @menuBtn = $('a.issue-menu')

    # Observe events
    this.observeEvents()


  trigger: (event, params...)->
    data = {
      method: event,
      params: params
    }

    frame = document.getElementById('issue-frame')
    from = frame.src.split("?")[0]
    
    XD.postMessage(JSON.stringify(data), from , frame.contentWindow );

  #
  # Observe viewer events from keyboard, user interaction and iframe messages
  #
  observeEvents: ->

  # Dispatched Iframe communication (MessageEvent)
  # Request { method: 'string', params: 'array', id: 'unique_id }
  # Request { result: 'object', id: 'unique_id }
  
    window.addEventListener 'message', (message)=>
      request = $.parseJSON(message.data)

      # go next/prev
      this[request.method]() if request.method.match(/next|prev/)

    , "http://#{request.host}"

    # UI Events
    $(document).on 'click', '.issue-menu', this.toggleMenu
    
    $(document).on 'click', '.next-page', (e)=> this.trigger("next-page")
    $(document).on 'click', '.prev-page', (e)=> this.trigger("prev-page")
    
    $(document).on 'click', '.issue-subscribe', -> false
    
    $(document).on "click", "nav.toc a", ->
      Viewer.goTo(@href)
      false
    
    # Keyboard events
    Mousetrap.bind "right", => this.trigger("next-page")
    Mousetrap.bind "left", => this.trigger("prev-page")
    Mousetrap.bind("option", this.toggleMenu)
    Mousetrap.bind("r", this.reload)

  load: (data)->
    @pages = data.pages

    $(@frame).after(data.menu_html)
    # @container.append()

  goTo: (path)->
    page = this.currentPage(path)
    
    page = "" if page == "index"
    
    @frame.src = @path + page + "?from=#{encodeURIComponent(document.location.href)}&embed=1"
    
    this.setCurrentPage(page) 


  next: ->
    current = this.currentPage()
    index = @pages.indexOf(current)

    if next = @pages[index + 1]
      this.goTo(next)
      
    false

  prev: ->
    current = @currentPage()
    index = @pages.indexOf(current)

    if prev = @pages[index - 1]
      this.goTo(prev)
    
    false

  toggleMenu: (state) ->
    nav = $("nav.toc")
    nav.toggleClass "show", state

    false

  # Private
  buildIframe: ->
    width = @container.width() || 1024

    # Build iframe
    iframe = document.createElement("iframe")
    iframe.id = iframe.name = "issue-frame"
    iframe.width = width
    iframe.height = width / 1.33
    iframe.scrolling = "no"
    iframe.frameBorder = "0"
    # iframe.style.overflow = "hidden"

    # iframe.src = @url + "?from=#{encodeURIComponent(document.location.href)}"

    @container.prepend(iframe)

    iframe
    
  currentPage: (path) ->
    path ||= @frame.src
    page = path.replace(@path, "").replace(/\?from=(.+)/, '')
    page ||= "index"
    page

  # Return parent path if possible, otherwise return self
  setCurrentPage: (path) ->
    page = path.replace(@path, "")
    parts = page.split(/\/|\?/)
    if parts.length > 1
      story = parts[0]
    else
      story = parts[0]

    @container.attr "data-page", story

    $("nav.toc a.active").removeClass "active"
    $("[data-page=\"" + story + "\"] .toc [class=\"" + story + "\"] a").addClass "active"
      
    this.toggleMenu(false)
      

  #App: ->
  #  document.getElementById('issue-frame').contentWindow.App || {}

  reload: ->
    $('#issue-frame').src = $('#issue-frame').src

# When dom ready
$ ->

  window.Viewer = Viewer
  Viewer.init(issue_url)

