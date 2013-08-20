miaServer = require '../lib/miaServer'
dgram = require 'dgram'
serverPort = 9000

describe 'udp communication', ->
  beforeEach ->
    @server = miaServer.start null, serverPort

  afterEach ->
    @server.shutDown()

  it 'handles a udp message', () ->
    @server.handleMessage = => @server.messageReceived = arguments
    socket = dgram.createSocket 'udp4'
    buffer = new Buffer('MESSAGE;ARG1;ARG2')
    socket.send buffer, 0, buffer.length, serverPort, 'localhost'
    waitsFor =>
      @server.messageReceived
    runs =>
      socket.close()
      expect(@server.messageReceived[0]).toEqual 'MESSAGE'
      expect(@server.messageReceived[1]).toEqual ['ARG1', 'ARG2']
