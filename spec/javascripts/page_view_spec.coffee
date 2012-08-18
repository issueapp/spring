#= require views

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
          #2
      createItem(3), createItem(4), # page 2
          #4                #
      createItem(5), createItem(6)  # page 3
          #6 end of s
    ]
    page = (id)->
      id: id
      limit: 2
      addItem: (item)-> @items.push(item)
      
    stream = new App.StreamCollection(items)
  
  it "has a length", ->
    expect(stream.length).toBe(6)
  
  it "has a offset as a current pointer (default: 0)", ->  
    expect(stream.offset).toBe(0)
  
  it "has end-of-stream (eos?)", ->
    expect(stream.eos()).toBe(false)
    
    stream.offset = stream.length
    
    expect(stream.eos()).toBe(true)
  
  describe "read forward (default)", ->
    
    it "fills up Page with items (page.limit) from beginning", ->
      stream.fill page()
    
      expect(stream.offset).toBe(2)
    
      stream.fill page()
      expect(stream.offset).toBe(4)
  
    it "fills up to the end", ->
      stream.offset = 4
    
      stream.fill p = page()
    
      expect( stream.eos() ).toBe(true)
      expect( p.items.length ).toBe(2)
    
      stream.offset = 5
    
      stream.fill p = page()

      expect( stream.eos() ).toBe(true)
      expect( p.items.length ).toBe(1)
    
  describe "reverse mode", ->
    
    it "fills up Pageview in reverse", ->
      stream.fill(page(), 4, true)

      expect(stream.offset).toBe(2)
    
    
    it "fills up Page in reverse up to beginging of stream", ->
      p = page()
      stream.fill(p, 2, true)
    
      expect(stream.offset).toBe(0)
      expect(p.items.length).toBe(2)

    it "shoudl not fill any item in reverse mode when it's at beginning of stream", ->
      p = page()
      stream.fill(p, 1, true)
  
      expect(stream.offset).toBe(0)
      expect(p.items.length).toBe(1)
      
      p = page()
      stream.fill(p, 0, true)
      
      expect(stream.offset).toBe(0)
      expect(p.items.length).toBe(0)
      
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
    
    

describe "PageView", ->
  
  it "render a div dom element", ->
  
  describe "#addItem", ->
    xit("something for later")
    
  describe "#addItem", ->
  
  describe ".plan", ->
    it "returns a array of PageView with number of view calculated.", ->
      expect(1).toEqual(1)
      
      # [
      #   { title: 'a', image_height: 100, image_width: 100 },
      #   { title: 'b', image_height: 200, image_width: 100 }, // tall
      #   { title: 'c', image_height: 100, image_width: 200 }, // tall
      # ]

    # v = new Foo()
    # expect(v.bar()).toEqual(false)
