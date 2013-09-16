window.miaBootstrap = ->
	html = JST['app/templates/mia.us']()
	document.body.innerHTML += html
	connectionViewModel = new window.ConnectionViewModel document.domain, 9000
	ko.applyBindings connectionViewModel
	window.mia.start()

$(window.miaBootstrap)
