miaServer = require '../lib/miaServer'
io = require('socket.io-client')
serverPort = 9000
ioPort = serverPort + 1
socketURL = "http://localhost:#{ioPort}"

describe 'socket.io communication', ->
	beforeEach (done) ->
		game = registerPlayer: (@registeredPlayer) =>
		@server = miaServer.start game, serverPort, =>
			@client = io.connect(socketURL)
			done()

	afterEach (done) ->
		@client.disconnect()
		@server.shutDown(done)


	it 'sends a message from client to server', (done) ->
		@server.handleMessage = => @server.messageReceived = arguments
		@client.on 'connect', =>
			@client.send 'MESSAGE;ARG1;ARG2'
		waitsFor =>
			@server.messageReceived?
		runs =>
			expect(@server.messageReceived[0]).toEqual 'MESSAGE'
			expect(@server.messageReceived[1]).toEqual ['ARG1', 'ARG2']
			expect(@server.messageReceived[2].id).toEqual @client.socket.sessionid
			done()
