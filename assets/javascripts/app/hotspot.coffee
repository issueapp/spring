class Hotspot extends Backbone.View
  el: ".hotspot"
  
  events:
    "click": "render"
  
  initialize: ->
    # @Page ||= { title: "Untitled page" }
    
  render: ->
    console.log($.el)
    
    @popover ||= _.template("""
    <div class="arrow"></div>
    <div class="details">
      <div class="thumb-image" style="background-image: url('<%%= image_url %>')"></div>
      <h1 class="title"><%%= title %></h1>
      <h2 class="subtitle">
        <%% if (typeof subtitle != "undefined" ) { %>
          <%%= subtitle %>,
        <%% } %>
        <%% if (typeof price != "undefined" ) { %>
          <%%= price %>
        <%% } %>
      </h2>
      <p class="description"><%%= description %></p>
    </div>
    <div class="actions">
    <a href="<%%= url %>" class="button small outline">shop now</a>
    </div>
    """)
    
    
# Export to global namespace (window or global)
this.Hotspot = Hotspot