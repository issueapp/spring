$("a.close-target").on "click", ->
  target = $(this).attr("href")
  $(target).hide()
  $(".overlay").hide()

$(".overlay").click ->
  $(".overlay").hide()
  $(".modal").hide()
  false

$(".open-modal").click ->
  $($(this).attr("href")).show()
  $(".overlay").show()
  false

$(".scroll-to").click ->
  $("html, body").animate
    scrollTop: $($(this).attr("href")).offset().top
  , 1000
  false
