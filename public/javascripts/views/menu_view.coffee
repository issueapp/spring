class App.MenuView extends Backbone.View
  el: "nav#menu"
  
  events:
    'touchstart ul.navigation li a': 'navigate'
  
  navigate: (e)->
    target = $(e.target)
    $(@el).find('li.active').removeClass('active')
    target.parent('li:not(.logo)').addClass('active')
    App.router.navigate(target.attr('href'), { trigger: true })
    
    e.preventDefault();