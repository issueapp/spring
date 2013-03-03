#   spring.ui.js
#
#     bare minimal javascrip to drive UI behavior
#     requires zepto or jquery
#
$ ->

  # Button dropdown
  $("body").on "click", (event) ->
    $(".dropdown-menu.hover").removeClass "buttonHover" if not $(event.target).hasClass("dropdown") and not $(event.target).hasClass("caret")

  $(".button.dropdown").on "click", ->
    dropdown = $(this).parent().children(".dropdown-menu")
    if dropdown.hasClass("buttonHover")
      dropdown.removeClass "buttonHover"
    else
      dropdown.addClass "buttonHover"
 
  # Dialog
  $(document).on "click", '.overlay', ->
    $('.overlay').hide()
    $('.modal').hide()
    false

  $("a.close-target").on "click", ->
    target = $(this).attr("href")
    $(target).hide()
    $(".overlay").hide()

  $('.open-modal').on "click", ->
    $($(this).attr('href')).show()
    $('.overlay').show()
    false
    
  # Scroll to
  $(".scroll-to").on "click", ->
     $('html, body').animate({
         scrollTop: $($(this).attr("href")).offset().top
     }, 1000)
     false
