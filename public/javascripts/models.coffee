class App.StreamCollection extends Backbone.Collection

  initialize: ->
    @offset = 0
    @perPage = 10

    # Server pagination
    @page = 1
    @currentPage = @prevPage = @nextPage = []

    this.on('fetch-next', this.fetchNext)
    this.on('fetch-prev', this.fetchPrev)

  # End of stream
  eos: ->
    @offset == @length

  # seek and fill a set of items into a page
  #     |   |
  # [a,b,c,d,e]
  #    ^
  # [ a,b,c;d,e,f,g;h,i,j;k,l,m,n; ] [ u, z, y ]
  #   |     |       |     |       |
  fill: (page, offset, reverse, isMobile)->
    reverse ||= false
    offset ||= @offset
    isMobile ||= false

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
      # console.warn("offset", offset, "limit", page.limit)
      offset = offset - page.limit

    else
      offset = offset

    this.each (item, index) =>
      if isMobile
        page.addItem( item.toJSON() )
      else
        lowerBound = index >= offset
        upperBound = index < offset + page.limit
        return false if !upperBound

        if lowerBound and upperBound
          page.addItem( item.toJSON() )

          if reverse
            current =  Math.max(offset + page.limit, 0)
          else
            current = index + 1

    # Load next page if needed
    # console.warn("loading", @loading, "offset", offset, "@currentPage.length", @currentPage.length)

    if !@loading && !reverse && offset > @currentPage.length/2
      @reverse = false
      this.trigger('fetch-next')
      @loading = true

    else if !@loading && reverse && offset < @currentPage.length/2
      @reverse = true
      this.trigger('fetch-prev')
      @loading = true

    @offset = page.offset = current

  fetchNext: ->
    # console.warn("fetch next")

    @page += 1

    if @url.indexOf("?") > -1
      url = "#{@url}&page=#{@page}&callback=?#fetch_next"
    else
      url = "#{@url}?page=#{@page}&callback=?#fetch_next"

    this.fetch({ silent: true, url: url, dataType: "jsonp" })

  fetchPrev: ->
    # console.warn('fetch prev')
    @page -= 1
    @page = Math.max(@page, 1)

    if @url.indexOf("?") > -1
      url = "#{@url}&page=#{@page}&callback=?#fetch_prev"
    else
      url = "#{@url}?page=#{@page}&callback=?#fetch_prev"

    this.fetch({ silent: true, url: url, dataType: "jsonp" })

  parse: (resp, xhr)->
    if @length == 0
      @currentPage = resp

    else if @nextPage.length == 0 && @currentPage.length > 0 && ! @reverse
      @nextPage = resp
      @loading = false
      @currentPage = @currentPage.concat(@nextPage)
      @nextPage = []
      return @currentPage

    else if @prevPage.length == 0 && @currentPage.length > 0 && @reverse
      @prevPage = resp
      @loading = false
      @currentPage = @currentPage.concat(@prevPage)
      @prevPage = []
      return @currentPage

    resp

  pageInfo: ->
    info = {
      total: @total
      page: @page
      perPage: @perPage
      pages: Math.ceil(@total / @perPage)
      prev: false
      next: false
    }

  findNext: (current)->
    current.collection.models[current.collection.models.indexOf(current) + 1]

  findPrev: (current)->
    current.collection.models[current.collection.models.indexOf(current) - 1]
