start = ->
  $.ajax
    type: 'GET'
    url: '/news/index?cache=true'
    async: true
    success: (result) ->
      $('table').replaceWith result
      return
  return

update = ->
  x = setInterval(start, 600*1000)
  start()
  return


$(document).ready update()
