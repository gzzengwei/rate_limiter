URL = '/home/index'

loadPing = ->
  status_code = null;
  fetch(URL)
    .then((res) ->
      status_code = res.status
      res.text()
    )
    .then (text) ->
      el = document.querySelector('ul#result')
      el.insertAdjacentHTML('beforeend', "<li>#{(new Date()).toLocaleTimeString()}: #{status_code} - #{text}</li>");

window.setInterval(loadPing, 1000)
