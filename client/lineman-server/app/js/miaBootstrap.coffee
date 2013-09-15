window.miaBootstrap = ->
	html = JST['app/templates/mia.us']()
	document.body.innerHTML += html
	connectionViewModel = new window.ConnectionViewModel document.domain, 9000
	console.log connectionViewModel
	ko.applyBindings connectionViewModel

	window.mia.start connectionViewModel

if window.addEventListener
	window.addEventListener('DOMContentLoaded', miaBootstrap, false)
else
	window.attachEvent('load', miaBootstrap)