miaServer = require '../lib/miaServer'
dgram = require 'dgram'
serverPort = 9000

describe 'udp communication', ->
	beforeEach ->
		game = registerPlayer: (@registeredPlayer) =>
		@server = miaServer.start game, serverPort
		@receiveMessageOnClient = ->
		@socket = dgram.createSocket 'udp4', (message, rinfo) => @receiveMessageOnClient(message, rinfo)
		@sendMessage = (message) =>
			buffer = new Buffer(message)
			@socket.send buffer, 0, buffer.length, serverPort, 'localhost'

	afterEach ->
		@socket.close()
		@server.shutDown()

	it 'sends a message from client to server', ->
		@server.handleMessage = => @server.messageReceived = arguments
		@sendMessage 'MESSAGE;ARG1;ARG2'
		waitsFor =>
			@server.messageReceived?
		runs =>
			expect(@server.messageReceived[0]).toEqual 'MESSAGE'
			expect(@server.messageReceived[1]).toEqual ['ARG1', 'ARG2']
			expect(@server.messageReceived[2].port).toEqual @socket.address().port

	it 'triggers client registration', ->
		@sendMessage 'REGISTER;client-name'
		waitsFor =>
			@registeredPlayer?
		runs =>
			expect(@registeredPlayer.name).toEqual 'client-name'

	it 'can receive a message on client from server after client registration', ->
		messageReceived = null
		@receiveMessageOnClient = (message) -> messageReceived = message.toString()
		@socket.bind()
		@sendMessage 'REGISTER;client-name'
		waitsFor =>
			messageReceived?
		runs =>
			expect(messageReceived).toEqual 'REGISTERED'
