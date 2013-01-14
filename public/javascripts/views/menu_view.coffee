class App.MenuView extends Backbone.View
  el: "nav#menu"

  events:
    'touchend ul.navigation li.logo a': 'home'
    'touchend ul.navigation li a': 'navigate'

  navigate: (e)->
    target = $(e.target)

    $(@el).find('li.active').removeClass('active')
    target.parent('li:not(.logo)').addClass('active')
    App.router.navigate(target.attr('href'), { trigger: true })

    e.preventDefault()

  home: (e)->
    target = $(e.target)
    App.router.navigate(target.attr('href'), { trigger: true })
    e.preventDefault()

  toggle: (display)->
    if display == false
      $(document.body).toggleClass('expand-menu', false)
    else if display == true
      $(document.body).toggleClass('expand-menu', true)
    else
      $(document.body).toggleClass('expand-menu')

    false
