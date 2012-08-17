# infinite scroll on iphone page
if $('.pagination').length
  $(window).scroll ->
    url = $('.pagination .next_page').attr('href')
    if url && pageYOffset > $(document).height() - $(window).height() - 50
      $('.pagination').text("Fetching more products...")
      $.get(url, (data)->
        doc = $(data)
        $('#products').append( doc.find('#products').html() )
        $('.pagination').html( doc.find('.pagination').html() )
      )
      
# ellipsis multiple lines by using Clamp.js
# https://github.com/josephschmitt/Clamp.js
$('.row.v-half figure.half:nth-child(2) .info p').each ->
  $clamp(this, {clamp: 10})

$('.col.half .v-third .info p').each ->
  $clamp(this, {clamp: 4})
  
doFlipClass = (classNames, oldName, newName)->
  classNames.forEach (className, index)->
    $('.rotatable').find(className).forEach (element)=>
      $(element).removeClass(oldName[index]).addClass(newName[index])

flipClass = ->
  page = $('.rotatable')
  
  if page.find('.v-half') && !page.find('.v-half').hasClass('row')
    doFlipClass(
      ['.v-half', '.v-third-2', '.v-third'],
      ['v-half', 'v-third-2', 'v-third'],
      ['half', 'third-2', 'third']
    )
  else
    doFlipClass(
      ['.half', '.third-2', '.third'],
      ['half', 'third-2', 'third'],
      ['v-half', 'v-third-2', 'v-third']
    )
  
  if page.find('.row.v-half').length > 0
    doFlipClass(['.row.v-half'], ['row v-half'], ['col half'])
  else
    doFlipClass(['.col.half'], ['col half'], ['row v-half'])
  
window.onorientationchange = ->
  flipClass()
  
# flipClass()

# doOnOrientationChange = ->
#   switch window.orientation
#     when -90, 90
#       "landscape"
#     else
#       "portrait"
# Initial execution
# doOnOrientationChange()