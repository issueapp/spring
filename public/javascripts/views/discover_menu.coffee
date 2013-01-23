class App.DiscoverMenu extends Backbone.View
  el: "#discover"
  
  events: 
    "keyup input[type=search]": "search"
    "tap a.follow": "toggleFollow"
    
  initialize: ->
    @collection = App.channels
    $(this.$el).hide()
    @input = this.$('input[type=search]')[0]
  
  render: (category)->
    this.$el.show()
    
    ## probably need better class highlighting
    $('#category li.active').removeClass('active');
    $("#category a[href='/#{Backbone.history.fragment}']").parent().addClass('active')

    if category
      @collection = _(App.channels).filter (channel)->
        channel.categories && _(channel.categories).find (cat)-> cat.toLowerCase() == category
    
    list = this.$('ul.channels').html('')
    
    template = Mustache.compile """
    <li data-id="{{ path }}" style="background-image: url({{ thumbnail_url }});">
      {{ name }}
      
      {{ #followed }}
        <a class="action follow followed" href="">-</a>
      {{ /followed }}
      
      {{ ^followed }}
        <a class="action follow" href="">+</a>
      {{ /followed}}        
        
      <a class="action view" rel="app" href="{{ path }}">&gt;</a>
    </li>
    """
    
    @collection.forEach (channel)-> 
      list.append template(channel)

  toggleFollow: (e)->
    channel = $(e.target).parent().data('id')
    
    App.channels.forEach (e)->
      if e.path == channel
        e.followed = !e.followed 
    
    this.render()
    App.menu.render()
    
    e.preventDefault()
    e.stopPropagation()
    false

  hide: -> 
    this.$el.hide()
    
  search: ->
    query = $(@input).val()
    
    @collection = _(App.channels).filter (channel)->
      channel.name.toLowerCase().match(query)

    this.render()