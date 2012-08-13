# infinite scroll on iphone page
if $('.pagination').length
  $(window).scroll ->
    url = $('.pagination .next_page').attr('href')
    if url && pageYOffset > $(document).height() - $(window).height() - 50
      $('.pagination').text("Fetching more products...")
      $.get(url, (data)->
        doc = $(data)
        $('#products').append( doc.find('#products').html() );
        $('.pagination').html( doc.find('.pagination').html() );
      )
      
# multiline ellipsis by using Clamp.js
$clamp($('.split .info p')[0], {clamp: 7});