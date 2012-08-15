#= require views

create_item = ()->
  
  title: "title"
  thumb: "/something"
  id: 1

describe "StreamView", ->
  view = new StreamView(items: [create_item, create_item, create_item])

  
  it "registers items", ->
    expect(view.items.length).toBe(3)
    

  it "fill items into multiple pages", ->
    loadFixtures 'templates'
    
    view.paginate()
    expect(view.pages.length).toBe(1)

describe "PageView", ->
  
  it "render a div dom element"
  
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
