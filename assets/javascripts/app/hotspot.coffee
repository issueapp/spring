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
    lookupKey= $(hotspot).attr('href')
    isProduct = $(hotspot).is('.product')

    # Use element attributes title, subtitle, summary
    if App.page

      if isProduct
        data = _(@page.products).find (p)-> lookupKey == p.url
        data.action = "shop"
      else
        data = _(@page.links).find (p)-> lookupKey == p.url

    data ||= {
      title:       $(hotspot).attr('title'),
      summary:     $(hotspot).data('summary'),
      subtitle:    $(hotspot).data('subtitle'),
      image_url:   $(hotspot).data('image_url'),
      description: $(hotspot).data('description'),
      url:         $(hotspot).attr('href').replace("#", ''),
    }

    data.action ||= "click"

    if data && data.title
      return data

  # Show popover dialog
  show: (e)=>
    @hotspot = $(e.currentTarget || @$el[0])
    console.log(@hotspot)
    data = this.lookup(@hotspot)

    console.log(data)

    this.render(data) if data

    false

  hide: (e)=>
    if $(e.target).closest('a').hasClass('hotspot')
      return

    if @popover && @popover.hasClass('show')
      @popover.remove()

      $('body').removeClass('stop-scrolling');
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
    <div class="product-popover dark-theme">
      <div class="arrow"></div>
      <div class="details">

        <% if (image_url) { %>
        <div class="thumb-image" style="background-image: url('<%= image_url %>')"></div>
        <% } %>

        <h1 class="title"><%= title %></h1>
        <h2 class="subtitle">

          <% if (typeof subtitle != "undefined" ) { %>
            <%= subtitle %>, <%= subtitle %>, <%= subtitle %>,
          <% } %>

          <% if (typeof price != "undefined" ) { %>
            <%= price %>
          <% } %>

        </h2>
        <div class="description"><%= description %></div>
      </div>

      <% if (url) { %>
        <div class="actions">

          <% if (action == "shop") { %>
            <a href="<%= url %>" class="button small outline" data-track="<%= action %>">Shop now</a>
          <% } else { %>
            <a href="<%= url %>" class="button small outline" data-track="<%= action %>">View more</a>
          <% } %>

        </div>
      <% } %>
    </div>
    """

    @popover.remove() if @popover

    @popover = $(_.template(template, data))
    $('body').append(@popover);

    popoverWidth = @popover.width()
    popoverHeight = @popover.height()

    arrow = @popover.find('.arrow')

    # Position popover/arrow
    if App.viewport.width > 480
      arrow.removeClass("up down left right")

      if document.body.offsetHeight - center_pos.y - dimension.height / 2 < @popover.height()
        arrowPosition = 'down'
        @popover.css('top', center_pos.y - dimension.height / 2 - @popover.height())

      # arrow point up
      else
        arrowPosition = "up"
        @popover.css "top", center_pos.y + dimension.height / 2 + spacing

      # arrow position left
      if center_pos.x < @popover.width() - arrowSpacing
        arrowPosition += " left"
        @popover.css "left", center_pos.x - arrowSpacing

      # arrow position right
      else
        arrowPosition += " right"
        @popover.css "left", center_pos.x - @popover.width() + arrowSpacing
      @popover.find(".arrow").addClass arrowPosition

    # show popover
    @popover.removeClass("hide").addClass "show"
    $('body').toggleClass('stop-scrolling');
    $('article.page .content').toggleClass('stop-scrolling');

# Export to global namespace (window or global)
this.Hotspot = Hotspot
