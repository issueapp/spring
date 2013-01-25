class App.PopoverView extends Backbone.View
  events:
    'touchend li a': 'toggleFocus'

  initialize: ->
    @popover_template = $('#popover_tpl').html()

  filterDropdown: (target)->
    data = {
      'type': 'filterDropdown'
      'collection': [
        { 'class': 'view-all active', 'link': '?type=all', 'content': 'view all' }
        { 'class': 'shop', 'link': '?type=product', 'content': 'shop' }
        { 'class': 'read', 'link': '?type=article', 'content': 'read' }
        { 'class': 'photo', 'link': '?type=picture', 'content': 'photo' }
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

  toggleFocus: (e)->
    target = $(e.currentTarget)
    target.parents('.popover').find('a').removeClass('active')
    target.addClass('active')

    # don't remove the timeout, otherwise navigation won't work
    setTimeout =>
      this.$el.hide()
    , 0

  resetFocus: ->
    this.$el.find('a').removeClass('active')
    this.$el.forEach (item)->
      $(item).find('li:first-child a').addClass('active')


