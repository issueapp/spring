class App.PopoverView extends Backbone.View
  events:
    'click li a': 'toggleFocus'

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
      'collection': [
        { 'link': '#1', 'content': 'Latest Arrivals', 'class': 'active' }
        { 'link': '#2', 'content': 'Editors choice' }
        { 'link': '#3', 'content': 'Promotions' }
      ]
    }

    html = $(Mustache.to_html(@popover_template, data))
    html.appendTo(target.parent())

  toggleFocus: (e)->
    $(e.currentTarget).parents('.popover').find('a').removeClass('active')
    $(e.currentTarget).addClass('active')

  resetFocus: ->
    this.$el.find('a').removeClass('active')
    this.$el.forEach (item)->
      $(item).find('li:first-child a').addClass('active')

