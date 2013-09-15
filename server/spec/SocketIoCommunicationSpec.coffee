miaServer = require '../lib/miaServer'
io = require('socket.io-client')
serverPort = 9000
socketURL = "http://localhost:#{serverPort}"

createClient = (onconnect) ->
	client = io.connect socketURL,
		'reconnect': false
		'force new connection': true
	client.on 'connect', onconnect
	client

describe 'socket.io communication', ->
	beforeEach (done) ->
		game = registerPlayer: (@registeredPlayer) =>
		@receiveMessageOnClient = ->
		@server = miaServer.start game, serverPort, =>
			@client = createClient =>
				@client.on 'message', (message) => @receiveMessageOnClient message
				done()

	afterEach (done) ->
		@client.disconnect()
		@server.shutDown done

	it 'sends a message from client to server', (done) ->
		@server.handleMessage = => @server.messageReceived = arguments
		@client.send 'MESSAGE;ARG1;ARG2'
		waitsFor =>
			@server.messageReceived?
		runs =>
			expect(@server.messageReceived[0]).toEqual 'MESSAGE'
			expect(@server.messageReceived[1]).toEqual ['ARG1', 'ARG2']
			done()

	it 'triggers client registration', (done) ->
		@client.send 'REGISTER;client-name'
		waitsFor =>
			@registeredPlayer?
		runs =>
			expect(@registeredPlayer.name).toEqual 'client-name'
			done()

	it 'can receive a message on client from server after client registration', (done) ->
		messageReceived = null
		@receiveMessageOnClient = (message) -> messageReceived = message
		@client.send 'REGISTER;client-name'
		waitsFor =>
			messageReceived?
		runs =>
			expect(messageReceived).toEqual 'REGISTERED'
			done()

	it 'allows a client to reconnect from the same IP address', (done) ->
		messageReceived = null
		@receiveMessageOnClient = (message) -> messageReceived = message
		@client.send 'REGISTER;client-name'
		waitsFor =>
			messageReceived?
		runs =>
			@client.disconnect()

			messageReceived = null
			@client = createClient =>
				@client.on 'message', (message) => @receiveMessageOnClient message
			@client.send 'REGISTER;client-name'
		waitsFor =>
			messageReceived?
		runs =>
			expect(messageReceived).toEqual 'REGISTERED'
			done()
