class Magazine extends Backbone.Model
  
  initialize: ->
  
  subscribe: ->
    
  download: ->

  status: ->
    
  parse: (data)->
    data.offline = _(window.offline_issues).find (issue)=>
      issue if issue.id == data.id
    
    data
#
#
#  collection.models =  [ "issue 1", "issue 2", "issue 3"]
#  
class MagazineCollection extends Backbone.Collection
  
  url: "/magazines.json"
  model: Magazine
  
  initialize: ->
    
  # search title, brand
  search: (query, filter)->
    console.log("Query: #{query}, filter: #{filter}, online: #{navigator.onLine}")
    
    # online
    if navigator.onLine && filter != "offline"
      
      # GET /magazines.json?q=query
      this.fetch(  data: { q: query, filter: filter } )
    
    # offline
    else
      issues = _(window.offline_issues).filter (issue)=>
        text = "#{issue.magazine_title} #{issue.title}"
        pattern = new RegExp(query, "i")
        
        text.match(pattern)
        
      this.reset(issues)
    
@Magazine = Magazine

@MagazineCollection = MagazineCollection



