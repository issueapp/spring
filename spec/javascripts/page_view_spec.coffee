#= require views

createItem = (id)->
  _.clone(
    title: "title"
    thumb: "/something"
    id: id
  )

describe "StreamCollection", ->
  stream = null
  
  beforeEach ->
    stream = new App.StreamCollection([createItem(), createItem(), createItem(), createItem(), createItem()])
  
  it "has a length", ->
    expect(stream.length).toBe(5)
  
  it "has a offset as a current pointer (default: 0)", ->  
    expect(stream.offset).toBe(0)
  
  it "has end-of-stream (eos?)", ->
    
    expect(stream.eos()).toBe(false)
    
    stream.offset = stream.length - 1
    expect(stream.eos()).toBe(true)
  
  it "fills a PageView", ->
    page = {
      limit: 2
      addItem: (item)->
        @items ||= []
        @items.push(item)
    }
    
    stream.fill(page)

    expect(stream.offset).toBe(1)
        
    stream.fill(_.clone(page))
    expect(stream.offset).toBe(2)


describe "StreamView", ->
  $(document.body).append('<div role="main">h1</div>')
  
  collection = new App.StreamCollection(createItem(), createItem(), createItem())
  
  view = new App.StreamView(collection: collection)
  
  it "registers items", ->
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
