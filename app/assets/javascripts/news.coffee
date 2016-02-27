update = ->
  $.ajax
    type: 'GET'
    url: '/news/index?cache=true'
    async: true
    success: (result) ->
      #I assume you want to do something on controller action execution success?
      $('table').replaceWith result
      return
  return

$(document).ready update()
