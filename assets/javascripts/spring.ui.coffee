#   spring.ui.js
#
#     bare minimal javascrip to drive UI behavior
#     requires zepto or jquery
#

# Button dropdown
$(document).on "click", "body", (event)->
  $(".dropdown-menu.hover").removeClass "buttonHover" if not $(event.target).hasClass("dropdown") and not $(event.target).hasClass("caret")
  
  $('.popover').hide()

$(document).on "click", ".button.dropdown", ->
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

$(document).on "click", '.open-target', ->
  target = $(this).attr("href")
  $(target).show()
  false

$(document).on "click", '.close-target', ->
  target = $(this).attr("href")
  $(target).hide()
  $(".overlay").hide()
  false

$(document).on "click", '.open-modal', ->
  $($(this).attr('href')).show()
  $('.overlay').show()
  false

  
# Scroll to
$(".scroll-to").on "click", ->
   $('html, body').animate({
       scrollTop: $($(this).attr("href")).offset().top
   }, 1000)
   false


# Update preview target when input field gets updated
#   Save original text in data attribute
#   Revert to original text when preview text is empty
$('.preview-target').each ->
  target = $($(this).data('target'))
  event = $(this).data('event') || "change"

  
  $(this).on event, => 
    text = $(this).val()
    
    if text.length > 0
      target.data('original', target.html()) unless target.data('original')
      target.html( text.replace(/\n/g, "<br/>") ) 
    else
      target.html(target.data('original'))