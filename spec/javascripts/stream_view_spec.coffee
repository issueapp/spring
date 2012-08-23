createItem = (id)->
  _.clone(
    title: "title"
    thumb: "/something"
    id: id
  )

describe "StreamCollection", ->
  stream = page = null
  
  beforeEach ->
    items = [
          #0               #1
      createItem(1), createItem(2), # page 1
          #2               #3
      createItem(3), createItem(4), 
      
          #4
      createItem(5), createItem(6),  # page 3
      
          #6 end of s
      createItem(7), createItem(8)  # page 3
          #8
    ]
    page = (id)->
      id: id
      limit: 2
      addItem: (item)-> @items.push(item)
      
    collection = new App.StreamCollection(items)
  
  it "has a length", ->
    expect(stream.length).toBe(8)
  
  it "has a offset as a current pointer (default: 0)", ->  
    expect(collection.offset).toBe(0)
  
  it "has end-of-stream (eos?)", ->
    expect(collection.eos()).toBe(false)
    
    collection.offset = collection.length
    
    expect(collection.eos()).toBe(true)
  
  describe "#read (forward)", ->
    
    it "reads items in forward direction", ->
      items = collection.read(2, 0)
      expect(items.count).toBe(2)
      expect(collection.offset).toBe(1)
      
    it "fills up Page with items (page.limit) from beginning", ->
      # 
      offset = firstPage.offset - currentPage.limit
      
      collection.read( - page.limit, offset)
      
      collection.offset
      
      # seek return a list of items or -1
      collection.read(2, 0)
          
      expect(collection.offset).toBe(2)
      
      # stream.fill page()
      collection.read(2, 2)
      
      expect(collection.offset).toBe(4)
  
    it "fills up to the end", ->
      stream.offset = stream.length - 2
    
      stream.fill p = page()
    
      expect( stream.eos() ).toBe(true)
      expect( p.items.length ).toBe(2)
    
      stream.offset = stream.length - 1
    
      stream.fill p = page()

      expect( stream.eos() ).toBe(true)
      expect( p.items.length ).toBe(1)
    
  describe "reverse mode", ->
    
    it "reads forward for 3 pages then sudden reverse", -> 
      stream.fill page(), 0
      
      stream.fill page(), 2
      
      stream.fill page(), 4
    
      expect( stream.offset ).toBe(6)
      
      stream.fill page(), 6, true
    
    it "fills up Pageview in reverse", ->
      stream.fill(page(), 4, true)

      expect(stream.offset).toBe(2)
    
    
    it "fills up Page in reverse up to beginging of stream", ->
      stream.read(-3, 0)
      
      p = page()
      stream.fill(p, 2, true)
    
      expect(stream.offset).toBe(0)
      expect(p.items.length).toBe(2)

    it "should not fill any item in reverse mode when it's at beginning of stream", ->
      p = page()
      stream.fill(p, 1, true)
  
      expect(stream.offset).toBe(0)
      expect(p.items.length).toBe(1)
      
      p = page()
      stream.fill(p, 0, true)
      
      expect(stream.offset).toBe(0)
      expect(p.items.length).toBe(0)
      
    it "step forward for 3 windows than back"
      
    # describe "Page index", ->
    #   
    #   #         0,  1 ;   2, 3   ;  4, 5
    #   #                      ^  
    #   #                   offset
    #   it "seeks across pages in reverse", ->
    #     [p1, p2, p3] = [ page(1), page(2), page(3) ]
    # 
    #     stream.fill( p1, 3, true)
    #     stream.fill( p2, 5, true)
    # 
    #     expect( p1.offset ).toBe(1)
    #     expect( p2.offset ).toBe(3)

describe "StreamView", ->
  collection = view = null
  
  beforeEach ->
    items = []
    until items.length == 20
      items.push createItem()
    
    if $('[role=main]').length == 0
      $(document.body).append('<div role="main" id="stream_view"></div>')
    
    collection = new App.StreamCollection(items)
    view = new App.StreamView(collection: collection, el: "#stream_view")
    
    loadFixtures('templates.html')

  describe "Initial render", ->
    
    it "builds pages in rendering window using a set limit (default: 3)", ->
      view.render()
      expect(view.pages.length).toBe(3)

    it "sets first page as current",->
      view.render()
      expect( $(view.pages[0].el).is('.current') ).toBe(true)
    
  # expect(view.items.length).toBe(3)
	
  it "fill items into multiple pages", ->
    # loadFixtures('templates.html')
    # console.log(view.el)
    # 
    # view.render()
    # 
    # console.log("something", view.pages, view.items)
    
