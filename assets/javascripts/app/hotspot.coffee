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

  spacing:      18
  arrowSpacing: 60

  template: _.template("""
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

        <% if (typeof price != "undefined") { %>
          <%= price %> <%= currency %>
        <% } %>

      </p>

      <% if (summary) { %>
        <div class="description"><%= summary %></div>
      <% } %>

    </div>

    <% if (action && link) { %>
      <footer>
        <% if (action == "shop") { %>
          <a href="<%= link %>" class="action button small outline" target="_blank" data-title="<%= link %>" title="<%= title %>" data-track="<%= action %>"

            <% if (typeof price != "undefined" ) { %>
              data-price="<%= price %>"
              data-currency="<%= currency %>"
            <% } %>

            >Shop now</a>

        <% } else if (action) { %>
          <a href="<%= link %>" class="action button small outline" data-track="<%= action %>" target="_blank"><%= action %></a>
        <% } else { %>
          <a href="<%= link %>" class="action button small outline" data-track="<%= action %>" target="_blank">View more</a>
        <% } %>

      </footer>
    <% } %>
  </div>
  """)

  initialize: (data)->
    @model  = data.model || App.currentPage.model
    @target = $(@el)

    this.lookup(@el)

  visit: (e)->
    link = e.currentTarget

    # google analytics custom campaign tracking params
    issue     = $('[data-issue]').data('issue')
    ga_params = "utm_source=issue.by&utm_campain=#{issue}&utm_content=#{encodeURI(App.currentPage.model.title)}"
    link.href += if link.href.match(/\?/) then '&' else '?'
    link.href += ga_params

    if App.support.webview
      App.trigger "open", link.href, linkTrackingAttributes(link)

      false

  # Lookup data and dimension of hotspot target
  lookup: (hotspot)->

    # Look up hotspot attributes or page object
    lookupKey = $(hotspot).data('url') || $(hotspot).attr('href')
    isProduct = $(hotspot).is('.product')

    defaultData = {
      url: null,
      image_url: null,
      description: null,
      action: "click"
    }

    # Use element attributes title, subtitle, summary
    if @model
      if isProduct
        data = _(@model.products).find (p)-> lookupKey == ( p.link || p.url )

        if typeof data == "undefined"
          console.log "Hotspot#lookup #{lookupKey} hotspot data"
          return

        data.action = "shop" if !data.action && data.action != false

        data.currency = null unless data.currency?
      else
        data = _(@model.links).find (p)-> lookupKey == ( p.link || p.url )

    data ||= {
      title:    $(hotspot).attr('title'),
      subtitle: $(hotspot).data('subtitle'),
      action:   $(hotspot).data('action'),
      summary:  $(hotspot).data('description'),
      link:     $(hotspot).attr('href').replace("#", '')
    }

    data.image_url = $(hotspot).data('image')
    data.summary = $("<div />").html(data.summary).text()

    # Backport summary and link
    console.log("Lookup hotspot:", lookupKey, data)

    @data = _.extend(defaultData, data)

  render: (position)->
    return unless @data

    this.track()

    $('.page-overlay').show() if App.viewport.width < 768

    $('.popover').remove()
    # @popover.remove() if @popover

    console.log("render hotspot dialog", @data)

    @popover = $( this.template(@data) )
    @popover.find('a').on "click", this.visit

    $('body').append(@popover)

    this.reposition(position)

    # $('body').addClass('stop-scrolling')
    # $('article.page .content').addClass('stop-scrolling')


  # Reposition popover to target element
  # TODO: calculate scroll offset
  reposition: (position)->
    console.log("reposition:", @target, position)

    # Dimension of target
    if @target.length > 0
      dimension = @target[0].getBoundingClientRect()
    else
      dimension = { height: 25, width: 0 }

    # Find center position of target or use supplied position
    position ||= {}

    unless position.x
      position = _.extend({
        x: dimension.left + dimension.width / 2,
        y: (dimension.top + $(window).scrollTop()) + dimension.height / 2
      }, position)

    popStyle = @popover[0].getBoundingClientRect()

    arrow = @popover.find('.arrow')

    # Position popover/arrow
    if App.viewport.width >= 768 || App.isAdmin

      arrow.removeClass("up down left right")

      if document.body.offsetHeight - position.y - dimension.height / 2 < popStyle.height
        arrowPosition = 'down'
        targetSpacing = dimension.height / 2

        if targetSpacing < @spacing
          targetSpacing = @spacing * 2

        @popover.css('top', position.y - targetSpacing - popStyle.height)

      # arrow point up
      else
        arrowPosition = "up"
        @popover.css "top", position.y + dimension.height / 2 + @spacing

      # Middle arrow

      if position.align == "middle"
        @popover.css "left", position.x - popStyle.width / 2

      # arrow position left
      else if position.align == "left" || position.x < popStyle.width - @arrowSpacing
        arrowPosition += " left"
        @popover.css "left", position.x - @arrowSpacing

      # arrow position right
      else
        arrowPosition += " right"
        @popover.css "left", position.x - popStyle.width + @arrowSpacing

      @popover.find(".arrow").addClass arrowPosition

    # show popover
    @popover.removeClass('show').addClass("show")


  track: =>
    title =  this.$el.attr('title') || this.$el.attr('data-title')
    data = {
      url:  this.$el.data("url") || this.el.href
      price:  this.$el.attr("data-price")
      currency:  this.$el.attr("data-currency")
      magazine: this.$el.parents("[data-magazine]").attr("data-magazine")
      issue: this.$el.attr("data-issue") || this.$el.parents("[data-issue]").attr("data-issue")
      page_id: this.$el.parents("[data-page-id]").attr("data-page-id")
    }

    App.trigger('track', 'hotspot:click', title , data)

  hide: (e)=>
    $('.overlay').hide()

    if $('.popover').length > 0
      return

    if @popover && @popover.hasClass('show')
      @popover.hide()

      setTimeout =>
        @popover.remove()
      , 100

      $('body').removeClass('stop-scrolling')
      $('article.page .content').removeClass('stop-scrolling')

# Export to global namespace (window or global)
this.Hotspot = Hotspot
