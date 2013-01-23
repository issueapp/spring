class App.GalleryView extends App.SwipeView
  el: '#gallery .swipe'

  # events:
    # 'click img': 'toggleText'

  goFullScreen: (e)->
    $el = this.$el
    $el.addClass('active')
    $('#gallery').append('<div class="overlay"></div>')
    # $el.append('<div class="toolbar"><a class="back">back</a><a class="share">share</a></div>')

  toggleText: (e)->
    this.$el.find('h1').toggle()

  # close: (e)->
  #   console.log(1)
