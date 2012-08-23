class App.StreamCollection extends Backbone.Collection
  
  initialize: ->
    @offset ||= 0
    @perPage ||= 10
    @page ||= 1
    
  # End of stream
  eos: ->
    @offset == @length

  # seek and fill a set of items into a page
  #     |   |
  # [a,b,c,d,e]
  #    ^
  # [ a,b,c;d,e,f,g;h,i,j;k,l,m,n; ]
  #   |     |       |     |       |
  fill: (page, offset, reverse)->
    reverse ||= false
    offset ||= @offset
    current = 0
    page.items ||= []
    # if reverse
    #   fromIndex = @offset - page.limit
    #   toIndex = @offset
    # else
    #   fromIndex = @offset
    #   toIndex = @offset + page.limit
    
    # return 0 if reverse && offset == 0
    
    if reverse
      offset = offset - page.limit
      
    else
      offset = offset
    
    this.each (item, index) =>
      lowerBound = index >= offset
      upperBound = index < offset + page.limit
      
      return false if !upperBound
      
      if lowerBound and upperBound
        page.addItem( item.toJSON() )
        
        if reverse
          current =  Math.max(offset + page.limit, 0)
        else
          current = index + 1
    
    console.log("Reverse: #{reverse}", offset, current, page.items.map (i)-> i.id )
    
    @offset = page.offset = current

  pageInfo: ->
    info = {
      total: @total
      page: @page
      perPage: @perPage
      pages: Math.ceil(@total / @perPage)
      prev: false
      next: false
    }
