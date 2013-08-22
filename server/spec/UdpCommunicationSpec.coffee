miaServer = require '../lib/miaServer'
dgram = require 'dgram'
serverPort = 9000

describe 'udp communication', ->
  beforeEach ->
    game = registerPlayer: (@registeredPlayer) =>
    @server = miaServer.start game, serverPort
    @socket = dgram.createSocket 'udp4'
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
      @server.messageReceived
    runs =>
      expect(@server.messageReceived[0]).toEqual 'MESSAGE'
      expect(@server.messageReceived[1]).toEqual ['ARG1', 'ARG2']
      expect(@server.messageReceived[2].port).toEqual @socket.address().port

  it 'triggers client registration', ->
    @sendMessage 'REGISTER;client-name;ARG2'
    waitsFor =>
      @registeredPlayer
    runs =>
      expect(@registeredPlayer.name).toEqual 'client-name'

