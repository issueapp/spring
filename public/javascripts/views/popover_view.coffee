class App.PopoverView extends Backbone.View
  events:
    'touchend li a': 'toggleFocus'

  initialize: ->
    @popover_template = $('#popover_tpl').html()

  filterDropdown: (target)->
    data = {
      'type': 'filterDropdown'
      'collection': [
        { 'class': 'view-all active', 'link': '?type=all', 'content': '<span></span>view all' }
        { 'class': 'shop', 'link': '?type=product', 'content': '<span></span>shop' }
        { 'class': 'read', 'link': '?type=article', 'content': '<span></span>read' }
        { 'class': 'photo', 'link': '?type=picture', 'content': '<span></span>photo' }
      ]
    }

    html = $(Mustache.to_html(@popover_template, data))
    html.appendTo(target.parent())

  collectionDropdown: (target)->
    data = {
      'type': 'collectionDropdown'
      'title': 'SELECTION'
      'collection': [
        { 'link': '#', 'content': 'Latest Arrivals', 'class': 'active' }
        { 'link': '#', 'content': 'Editors choice' }
        { 'link': '#', 'content': 'Promotions' }
      ]
    }

    html = $(Mustache.to_html(@popover_template, data))
    html.appendTo(target.parent())

  shareDropdown: (target)->
    # facebook share link
    # http://www.facebook.com/sharer.php?s=100&amp;
    # p[url]=http://shop2.com/markguo&amp;
    # p[title]=Women's Party Dresses, Casual Dresses, Fall &amp;amp; Summer Dresses&amp;
    # p[summary]=Hey, check out Women's Party Dresses, Casual Dresses, Fall &amp;amp; Summer Dresses @shop2. Follow my shopping discoveries and start your personal shopping catalog.&amp;
    # p[images][0]=http://s7.madewell.com/is/image/madewell/32181_WE2657_m?$cat_tn250$

    data = {
      'type': 'shareDropdown'
      'collection': [
        { 'link': '#', 'content': '<i class="icon-facebook"></i>Facebook', 'class': 'facebook' }
        { 'link': '#', 'content': '<i class="icon-twitter"></i>Twitter', 'class': 'twitter' }
        { 'link': '#', 'content': '<i class="icon-pinterest"></i>Pinterest', 'class': 'pinterest' }
      ]
    }

    html = $(Mustache.to_html(@popover_template, data))
    html.appendTo(target.parent())

  toggleFocus: (e)->
    target = $(e.currentTarget)
    target.parents('.popover').find('a').removeClass('active')
    target.addClass('active')

  resetFocus: ->
    this.$el.find('a').removeClass('active')
    this.$el.forEach (item)->
      $(item).find('li:first-child a').addClass('active')
