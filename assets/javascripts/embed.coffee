`
/* mousetrap v1.4.6 craig.is/killing/mice */
(function(J,r,f){function s(a,b,d){a.addEventListener?a.addEventListener(b,d,!1):a.attachEvent("on"+b,d)}function A(a){if("keypress"==a.type){var b=String.fromCharCode(a.which);a.shiftKey||(b=b.toLowerCase());return b}return h[a.which]?h[a.which]:B[a.which]?B[a.which]:String.fromCharCode(a.which).toLowerCase()}function t(a){a=a||{};var b=!1,d;for(d in n)a[d]?b=!0:n[d]=0;b||(u=!1)}function C(a,b,d,c,e,v){var g,k,f=[],h=d.type;if(!l[a])return[];"keyup"==h&&w(a)&&(b=[a]);for(g=0;g<l[a].length;++g)if(k=
l[a][g],!(!c&&k.seq&&n[k.seq]!=k.level||h!=k.action||("keypress"!=h||d.metaKey||d.ctrlKey)&&b.sort().join(",")!==k.modifiers.sort().join(","))){var m=c&&k.seq==c&&k.level==v;(!c&&k.combo==e||m)&&l[a].splice(g,1);f.push(k)}return f}function K(a){var b=[];a.shiftKey&&b.push("shift");a.altKey&&b.push("alt");a.ctrlKey&&b.push("ctrl");a.metaKey&&b.push("meta");return b}function x(a,b,d,c){m.stopCallback(b,b.target||b.srcElement,d,c)||!1!==a(b,d)||(b.preventDefault?b.preventDefault():b.returnValue=!1,b.stopPropagation?
b.stopPropagation():b.cancelBubble=!0)}function y(a){"number"!==typeof a.which&&(a.which=a.keyCode);var b=A(a);b&&("keyup"==a.type&&z===b?z=!1:m.handleKey(b,K(a),a))}function w(a){return"shift"==a||"ctrl"==a||"alt"==a||"meta"==a}function L(a,b,d,c){function e(b){return function(){u=b;++n[a];clearTimeout(D);D=setTimeout(t,1E3)}}function v(b){x(d,b,a);"keyup"!==c&&(z=A(b));setTimeout(t,10)}for(var g=n[a]=0;g<b.length;++g){var f=g+1===b.length?v:e(c||E(b[g+1]).action);F(b[g],f,c,a,g)}}function E(a,b){var d,
c,e,f=[];d="+"===a?["+"]:a.split("+");for(e=0;e<d.length;++e)c=d[e],G[c]&&(c=G[c]),b&&"keypress"!=b&&H[c]&&(c=H[c],f.push("shift")),w(c)&&f.push(c);d=c;e=b;if(!e){if(!p){p={};for(var g in h)95<g&&112>g||h.hasOwnProperty(g)&&(p[h[g]]=g)}e=p[d]?"keydown":"keypress"}"keypress"==e&&f.length&&(e="keydown");return{key:c,modifiers:f,action:e}}function F(a,b,d,c,e){q[a+":"+d]=b;a=a.replace(/\s+/g," ");var f=a.split(" ");1<f.length?L(a,f,b,d):(d=E(a,d),l[d.key]=l[d.key]||[],C(d.key,d.modifiers,{type:d.action},
c,a,e),l[d.key][c?"unshift":"push"]({callback:b,modifiers:d.modifiers,action:d.action,seq:c,level:e,combo:a}))}var h={8:"backspace",9:"tab",13:"enter",16:"shift",17:"ctrl",18:"alt",20:"capslock",27:"esc",32:"space",33:"pageup",34:"pagedown",35:"end",36:"home",37:"left",38:"up",39:"right",40:"down",45:"ins",46:"del",91:"meta",93:"meta",224:"meta"},B={106:"*",107:"+",109:"-",110:".",111:"/",186:";",187:"=",188:",",189:"-",190:".",191:"/",192:"\`",219:"[",220:"\\",221:"]",222:"'"},H={"~":"\`","!":"1",
"@":"2","#":"3",$:"4","%":"5","^":"6","&":"7","*":"8","(":"9",")":"0",_:"-","+":"=",":":";",'"':"'","<":",",">":".","?":"/","|":"\\"},G={option:"alt",command:"meta","return":"enter",escape:"esc",mod:/Mac|iPod|iPhone|iPad/.test(navigator.platform)?"meta":"ctrl"},p,l={},q={},n={},D,z=!1,I=!1,u=!1;for(f=1;20>f;++f)h[111+f]="f"+f;for(f=0;9>=f;++f)h[f+96]=f;s(r,"keypress",y);s(r,"keydown",y);s(r,"keyup",y);var m={bind:function(a,b,d){a=a instanceof Array?a:[a];for(var c=0;c<a.length;++c)F(a[c],b,d);return this},
unbind:function(a,b){return m.bind(a,function(){},b)},trigger:function(a,b){if(q[a+":"+b])q[a+":"+b]({},a);return this},reset:function(){l={};q={};return this},stopCallback:function(a,b){return-1<(" "+b.className+" ").indexOf(" mousetrap ")?!1:"INPUT"==b.tagName||"SELECT"==b.tagName||"TEXTAREA"==b.tagName||b.isContentEditable},handleKey:function(a,b,d){var c=C(a,b,d),e;b={};var f=0,g=!1;for(e=0;e<c.length;++e)c[e].seq&&(f=Math.max(f,c[e].level));for(e=0;e<c.length;++e)c[e].seq?c[e].level==f&&(g=!0,
b[c[e].seq]=1,x(c[e].callback,d,c[e].combo,c[e].seq)):g||x(c[e].callback,d,c[e].combo);c="keypress"==d.type&&I;d.type!=u||w(a)||c||t(b);I=g&&"keydown"==d.type}};J.Mousetrap=m;"function"===typeof define&&define.amd&&define(m)})(window,document);
`

@App = {}

unless jQuery? || Zepto?
  return alert("Error: Jquery or Zepto is required")

base_url = "http://spring.dev/"


##
# Detect magazine and issue params
# 
file = (script.src for script in document.getElementsByTagName('script') when script.src.match(/embed\.js/))

parser = document.createElement('a')
parser.href = file

if matches = parser.search.match(/magazine=([^&]+)/)
  magazine = matches[1]
else
  alert("Error: Require a valid magazine params ")

if matches = parser.search.match(/issue=([^&]+)/)
  issue = matches[1]
else
  issue = null


issue_url = base_url + "#{magazine}/#{issue}"
# issue_url = "http://spring.dev/issues/#{issue}"



#
#  Issue viewer
#
Viewer =
  
  # http://localhost:3000/issue
  # file:///var/a/b/d/issue
  path: null
  
  init: (url) ->
    
    @url = url
    
    @container = $("#issue-viewer").css({
      'background': "#fff"
    })
    
    @container = document.body if @container.length == 0
    
    parts = url.split('/')
    parts.pop()  if parts.length > 5
    @path = parts.join("/")
    
    console.log("Init viewer", @path)
    
    # Build iframe
    @frame = this.buildIframe()
    
    # Load pages and menu
    $.getJSON issue_url + '/issue.json?callback=?', (data)-> 
      Viewer.load(data)
    
    # Observe events
    @nextBtn = $('<a class="next-page" href="#">›</a>')
    @prevBtn = $('<a class="prev-page" href="#">‹</a>')
    
    
    # Set current page
    this.setCurrentPage( @currentPage() )
    
    @nextBtn.on "click", $.proxy(this.next, this)
    @prevBtn.on "click", $.proxy(this.prev, this)
    @container.prepend(@nextBtn).prepend(@prevBtn)

    Mousetrap.bind("right", $.proxy(this.next, this))
    Mousetrap.bind("left", $.proxy(this.prev, this))
    Mousetrap.bind("option", this.toggleMenu)
    Mousetrap.bind("r", this.reload)
    
    $("nav.toc a").on "click", ->
      
      link = @href
      link = link.replace(/\/viewer\//, "/issues/")  if link.match(/\/viewer\//)
      
      Viewer.setCurrentPage link
      Viewer.toggleMenu()
      false
    

  load: (data)->
    @pages = data.pages
    
    $(@frame).after(data.menu_html)
    # @container.append()

  next: ->
    current = this.currentPage()
    index = @pages.indexOf(current)
    next = @pages[index + 1]

    console.log("Go Next", current, index, next)

    # Set App glob
    App = this.App()
    
    # console.log(App)
    
    # console.log(">> current", current)
    # console.log(">> index", index)
    # console.log(">> next", next)
    
    if App.pageView && App.pageView.canScroll()
      App.pageView.next()
      
    else if next
      $("#issue-frame").attr "src", @path + "/" + next
      
      $("#issue-frame").off('load').on 'load', =>
      
        @setCurrentPage next
        @toggleMenu false

    false

  goTo: (path)->
      $("#issue-frame").attr "src", path

  prev: ->

    # Set App glob
    App = this.App()
    
    current = @currentPage()
    index = @pages.indexOf(current)
    prev = @pages[index - 1]
    
    if App.pageView && App.pageView.canScroll('left')
      App.pageView.prev()
      
    else if prev
      
      $("#issue-frame").attr "src", @path + "/" + prev
      
      $("#issue-frame").off('load').on 'load', =>
      
        @setCurrentPage prev
        @toggleMenu false

        # Set App glob
        App = this.App()
    
    false


  currentPage: (story) ->
    src = @frame.src
    page = undefined
    
    if src.match(@path + "/")
      page = @frame.src.replace(@path + "/", "")
    else
      page = "index"
    page

  toggleMenu: (state) ->
    nav = $("nav.toc")
    nav.toggleClass "show", state
  
  # Private
  buildIframe: ->
    
    width = @container.width() || 1024
    
    # Build iframe
    iframe = document.createElement("iframe")
    iframe.id = "issue-frame"
    iframe.width = width 
    iframe.height = width / 1.33
    iframe.scrolling = "no"
    iframe.frameBorder = "0"
    
    # iframe.style.overflow = "hidden"
    # 
    @container.prepend(iframe)
    iframe.src = @url
    iframe
    
  # Return parent path if possible, otherwise return self
  setCurrentPage: (path) ->
    page = path.replace(@path + "/", "")
    parts = page.split(/\/|\?/)
    if parts.length > 1
      story = parts[0]
    else
      story = parts[0]
      
    @container.attr "data-page", story
    
    
    $("nav.toc a.active").removeClass "active"
    $("[data-page=\"" + story + "\"] .toc [class=\"" + story + "\"] a").addClass "active"
  
  App: ->
    document.getElementById('issue-frame').contentWindow.App || {}

  reload: ->
    document.getElementById("issue-frame").contentWindow.location.reload()
    

# When dom ready
$ -> 

  window.Viewer = Viewer
  Viewer.init(issue_url)
  
  
  