class @DiscoverView extends Backbone.View
  el: ".search-view"
  
  events: 
    'submit form.search-issue': 'search'
    'click a[data-filter]': 'filter'
    'keyup input.search': "quickSearch"
  
  initialize: ->
    
    if navigator.onLine
      @currentFilter = "all"
    else
      @currentFilter = "offline"
    
    @filters = ["all", "featured", "offline"]
    
    @listView = new MagazineList
    
    @collection = @listView.collection
    
    # GET /magazines.json
    @collection.fetch()
  
  render: ->
    this.$('.filters')
    
  
  search: ()->
    query = this.$('input.search').val()
    
    console.log("searching", query)
      
    # GET /magazines.json?q=text
    @collection.search(query, @currentFilter)
    
    false
  
  quickSearch: _.debounce(
    (e)-> this.search(e)
    200
  )
  
  filter: (e)->
    this.$('.filters a[data-filter]').removeClass('active')
      
    @currentFilter = $(e.currentTarget).addClass('active').attr('data-filter')
    
    this.search()
    
    false

class @MagazineList extends Backbone.View
  
  el: ".magazine-list"
  
  initialize: (data)->
    data ||= {}
    @collection = new MagazineCollection unless data.collection
    
    @collection.on 'reset', this.render
    
  render: =>
    this.$el.empty()
    
    @views = @collection.each this.addItem
    
  addItem: (magazine)=>
    
    template = $('#magazine_tpl').html()
    
    html = Mustache.render(template, magazine.toJSON())
        
    this.$el.append( html )
