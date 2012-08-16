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
      
# ellipsis 7 lines by using Clamp.js
# https://github.com/josephschmitt/Clamp.js
$('.row.v-half figure.half:nth-child(2) .info p').each ->
  $clamp(this, {clamp: 10})

$('.col.half .v-third .info p').each ->
  $clamp(this, {clamp: 4})