#= require views

describe "PageView", ->
  describe ".plan", ->
    it "returns a array of PageView with number of view calculated.", ->
      expect(1).toEqual(1)
      console.log PageView
      
      # [
      #   { title: 'a', image_height: 100, image_width: 100 },
      #   { title: 'b', image_height: 200, image_width: 100 }, // tall
      #   { title: 'c', image_height: 100, image_width: 200 }, // tall
      # ]

    # v = new Foo()
    # expect(v.bar()).toEqual(false)
