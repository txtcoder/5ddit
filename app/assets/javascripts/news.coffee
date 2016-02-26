update = ->
  $.ajax
    type: 'GET'
    url: '/news/index?cache=true'
    success: (result) ->
      #I assume you want to do something on controller action execution success?
      $('body').replaceWith result
      return
  return

$(document).ready update()
