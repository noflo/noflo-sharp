noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  ResizeBuffer = require '../components/ResizeBuffer-node.coffee'
  testutils = require './testutils'
  sharp = require 'sharp'
else
  ResizeBuffer = require 'noflo-sharp/components/ResizeBuffer.js'
  testutils = require 'noflo-image/spec/testutils.js'

describe 'ResizeBuffer component', ->
  c = null
  ins = null
  width = null
  height = null
  factor = null
  out = null
  beforeEach ->
    c = ResizeBuffer.getComponent()
    ins = noflo.internalSocket.createSocket()
    width = noflo.internalSocket.createSocket()
    height = noflo.internalSocket.createSocket()
    factor = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.buffer.attach ins
    c.inPorts.width.attach width
    c.inPorts.height.attach height
    c.outPorts.factor.attach factor
    c.outPorts.buffer.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.buffer).to.be.an 'object'
      chai.expect(c.inPorts.width).to.be.an 'object'
      chai.expect(c.inPorts.height).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.factor).to.be.an 'object'
      chai.expect(c.outPorts.buffer).to.be.an 'object'

  describe 'when passed an image', ->
    original =
      width: 512
      height: 512
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 128
        height: 256
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()

      width.send expected.width
      height.send expected.height
      testutils.getBuffer __dirname + '/fixtures/foo.jpeg', (buffer) ->
        ins.send buffer

    it 'should resize it right when given just width', (done) ->
      expected =
        width: 128
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.width
          done()

      width.send expected.width
      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer

    it 'should resize it right when given just height', (done) ->
      expected =
        height: 128
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.height
          chai.expect(meta.height).to.be.equal expected.height
          done()

      height.send expected.height
      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer

    it 'should resize it right to default dimension', (done) ->
      expected =
        width: 256
        height: 256
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()

      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer

    it 'should not resize up (just down, without enlargement)', (done) ->
      expected =
        width: 512
        height: 512
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()

      width.send 1024
      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer

  describe 'when passed a GIF', ->
    original =
      width: 500
    it 'should resize it to the specified dimension', (done) ->
      @timeout 5000
      expected =
        width: 256
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          done()

      width.send expected.width
      testutils.getBuffer __dirname + '/fixtures/foo.gif', (buffer) ->
        ins.send buffer

  describe 'when passed a JPG', ->
    original =
      width: 2048
      height: 1536
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 1024
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          done()

      width.send expected.width
      testutils.getBuffer __dirname + '/fixtures/foo.jpeg', (buffer) ->
        ins.send buffer

  describe.skip 'when passed a WEBP', ->
    original =
      width: 550
      height: 404
    it 'should resize it to the specified dimension', (done) ->
      @timeout 10000
      expected =
        width: 256
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          done()

      width.send expected.width
      testutils.getBuffer __dirname + '/fixtures/foo.webp', (buffer) ->
        ins.send buffer

  describe 'when passed a TIFF', ->
    original =
      width: 1076
      height: 750
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 256
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          done()

      width.send expected.width
      testutils.getBuffer __dirname + '/fixtures/foo.tif', (buffer) ->
        ins.send buffer
