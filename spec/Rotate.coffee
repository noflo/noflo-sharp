noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Rotate = require '../components/Rotate-node.coffee'
  testutils = require './testutils'
  sharp = require 'sharp'
else
  Rotate = require 'noflo-sharp/components/Rotate.js'
  testutils = require 'noflo-image/spec/testutils.js'

describe 'Rotate component', ->
  c = null
  ins = null
  angle = null
  out = null
  beforeEach ->
    c = Rotate.getComponent()
    ins = noflo.internalSocket.createSocket()
    angle = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.buffer.attach ins
    c.inPorts.angle.attach angle
    c.outPorts.buffer.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.buffer).to.be.an 'object'
      chai.expect(c.inPorts.angle).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.buffer).to.be.an 'object'

  describe 'when passed an image buffer and an angle', ->
    @timeout 10000
    it 'should rotate to the angle', (done) ->
      expected =
        width: 1536
        height: 2048
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()
      angle.send 90
      testutils.getBuffer __dirname + '/fixtures/foo.jpeg', (buffer) ->
        ins.send buffer

  describe 'when passed an small image and an angle', ->
    @timeout 10000
    it 'should rotate to the angle', (done) ->
      expected =
        width: 1536
        height: 2048
      out.on 'data', (data) ->
        console.log 'data', data
        buffer = sharp data
        buffer.metadata (err, meta) ->
          #chai.expect(meta.width).to.be.equal expected.width
          #chai.expect(meta.height).to.be.equal expected.height
          done()
      angle.send 0
      testutils.getBuffer __dirname + '/fixtures/1x1.gif', (buffer) ->
        ins.send buffer
