window.miaBootstrap = ->
	html = JST['app/templates/mia.us'] {
		address: window.mia.address
		port: window.mia.port
	}
	document.body.innerHTML += html
	window.mia.start window.mia

if window.addEventListener
	window.addEventListener('DOMContentLoaded', miaBootstrap, false)
else
	window.attachEvent('load', miaBootstrap)