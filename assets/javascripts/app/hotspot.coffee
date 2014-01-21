#
# Hotspot
#
# Products or other resources
#
# App.page = {
#
# }
# a.hotspot.product
#

class Hotspot extends Backbone.View
  el: ".hotspot"

  events:
    "click": "show"

  initialize: (data)->
    @page = data.page || App.page

    $('body').on 'click', this.hide

  # Lookup data and dimension of hotspot target
  lookup: (hotspot)->

    # Look up hotspot attributes or page object
    lookupKey = $(hotspot).attr('href')
    isProduct = $(hotspot).is('.product')

    defaultData = {
      url: null,
      image_url: null,
      description: null,
      action: "click"
    }

    # Use element attributes title, subtitle, summary
    if App.page
      if isProduct
        data = _(@page.products).find (p)-> lookupKey == p.url
        data.action = "shop" if data
      else
        data = _(@page.links).find (p)-> lookupKey == p.url

    data ||= {
      title:       $(hotspot).attr('title'),
      subtitle:    $(hotspot).data('subtitle'),
      image_url:   $(hotspot).data('image'),
      action:   $(hotspot).data('action'),
      description: $(hotspot).data('description'),
      url:         $(hotspot).attr('href').replace("#", ''),
    }

    data = _.extend(defaultData, data)

    if data && data.title
      return data

  # Show popover dialog
  show: (e)=>
    hotspot = $(e.currentTarget || @$el[0])

    if @hotspot == hotspot
      return
    else
      @hotspot = hotspot

    data = this.lookup(@hotspot)

    console.log(data, @hotspot)

    this.render(data) if data

    false

  hide: (e)=>

    if $(e.target).parents('.product-popover').length > 0
      console.log("ignore")
      return

    if @popover && @popover.hasClass('show')
      @popover.remove()

      $('body').removeClass('stop-scrolling')
      $('article.page .content').removeClass('stop-scrolling')

  render: (data)->
    return data unless data

    spacing       = 18
    arrowSpacing  = 110

    dimension = @hotspot[0].getBoundingClientRect()
    center_pos = {
      x: dimension.left + dimension.width / 2,
      y: dimension.top + dimension.height / 2
    }

    template = """
    <div class="popover dark-theme">
      <div class="arrow"></div>
      <div class="content">

        <% if (image_url) { %>
        <img src="<%= image_url %>" class="thumb-image" >
        <% } %>

        <h3 class="title"><%= title %></h3>
        <p class="subtitle">

          <% if (typeof subtitle != "undefined" ) { %>
            <%= subtitle %>
          <% } %>

          <% if (typeof price != "undefined" ) { %>
            <%= price %>
          <% } %>

        </p>

        <% if (description) { %>
          <div class="description"><%= description %></div>
        <% } %>

      </div>

      <% if (url) { %>
        <footer>

          <% if (action == "shop") { %>
            <a href="<%= url %>" class="button small outline" data-track="<%= action %>">Shop now</a>
          <% } else { %>
            <a href="<%= url %>" class="button small outline" data-track="<%= action %>">View more</a>
          <% } %>

        </footer>
      <% } %>
    </div>
    """


    @popover.remove() if @popover

    @popover = $(_.template(template, data))
    $('body').append(@popover)

    popStyle = @popover[0].getBoundingClientRect()
    
    arrow = @popover.find('.arrow')

    # Position popover/arrow
    if App.viewport.width > 480
      arrow.removeClass("up down left right")

      if document.body.offsetHeight - center_pos.y - dimension.height / 2 < popStyle.height
        arrowPosition = 'down'
        targetSpacing = dimension.height / 2

        if targetSpacing < spacing
          targetSpacing = spacing * 2

        @popover.css('top', center_pos.y - targetSpacing - popStyle.height)

      # arrow point up
      else
        arrowPosition = "up"
        @popover.css "top", center_pos.y + dimension.height / 2 + spacing

      # arrow position left
      if center_pos.x < popStyle.width - arrowSpacing
        arrowPosition += " left"
        @popover.css "left", center_pos.x - arrowSpacing

      # arrow position right
      else
        arrowPosition += " right"
        @popover.css "left", center_pos.x - popStyle.width + arrowSpacing
      @popover.find(".arrow").addClass arrowPosition

    # show popover
    @popover.removeClass("hide").addClass("show")
    $('body').toggleClass('stop-scrolling')
    $('article.page .content').toggleClass('stop-scrolling')

# Export to global namespace (window or global)
this.Hotspot = Hotspot
