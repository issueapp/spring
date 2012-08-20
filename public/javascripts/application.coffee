# infinite scroll on iphone page
# if $('.pagination').length
#   $(window).scroll ->
#     url = $('.pagination .next_page').attr('href')
#     if url && pageYOffset > $(document).height() - $(window).height() - 50
#       $('.pagination').text("Fetching more products...")
#       $.get(url, (data)->
#         doc = $(data)
#         $('#products').append( doc.find('#products').html() )
#         $('.pagination').html( doc.find('.pagination').html() )
#       )

# ellipsis multiple lines by using Clamp.js
# https://github.com/josephschmitt/Clamp.js
clampInfo = ->
  $('.half.split .info p').each ->
    $clamp(this, {clamp: 10})

  $('.v-third.split .info p').each ->
    $clamp(this, {clamp: 4})

removeClamp = ->
  $('.info p').css('display', '')


doFlipClass = (classNames, oldNames, newNames)->
  classNames.forEach (className, index)->
    $('.rotatable').find(className).forEach (element)=>
      $(element).removeClass(oldNames[index]).addClass(newNames[index])

flipClass = ->
  page = $('.rotatable')
  
  if page.find('.v-half') && !page.find('.v-half').hasClass('row')
    doFlipClass(
      ['.v-half.nosplit', '.v-half', '.v-third-2', '.v-third.split', '.v-third'],
      ['v-half nosplit', 'v-half', 'v-third-2', 'v-third split', 'v-third'],
      ['half split', 'half', 'third-2', 'third nosplit', 'third']
    )
  else
    doFlipClass(
      ['.half.split', '.half', '.third-2', '.third.nosplit', '.third'],
      ['half split', 'half', 'third-2', 'third nosplit', 'third'],
      ['v-half nosplit', 'v-half', 'v-third-2', 'v-third split', 'v-third']
    )
  
  if page.find('.row.v-half').length > 0
    doFlipClass(['.row.v-half'], ['row v-half'], ['col half'])
  else
    doFlipClass(['.col.half'], ['col half'], ['row v-half'])
  
doOnOrientationChange = ->
  switch window.orientation
    when -90, 90
      "landscape"
    else
      "portrait"

window.onorientationchange = ->
  flipClass()
  
  if doOnOrientationChange() == "portrait"
    removeClamp()
  else
    clampInfo()

$('.next-version').click ->
  # random version
  # version = Math.floor(Math.random() * 6) + 1
  # query = window.location.search
  # if query != ""
  #   while parseInt(query.substr(query.length - 1)) == version
  #     version = Math.floor(Math.random() * 6) + 1
  
  query = window.location.search
  if query != ""
    version = parseInt(query.substr(query.length - 1)) + 1
    if version == 7
      version = 1
    window.location = 'http://localhost:4000/ipad?version=v' + version

clampInfo()  
# flipClass()
