noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Extract = require '../components/Extract-node.coffee'
  testutils = require './testutils'
  sharp = require 'sharp'
else
  Extract = require 'noflo-sharp/components/Extract.js'
  testutils = require 'noflo-image/spec/testutils.js'

describe 'Extract component', ->
  c = null
  ins = null
  rect = null
  out = null
  beforeEach ->
    c = Extract.getComponent()
    ins = noflo.internalSocket.createSocket()
    rect = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.buffer.attach ins
    c.inPorts.rect.attach rect
    c.outPorts.buffer.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.buffer).to.be.an 'object'
      chai.expect(c.inPorts.rect).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.buffer).to.be.an 'object'

  describe 'when passed an image buffer', ->
    @timeout 10000
    it 'should extract a new buffer with the specified dimensions', (done) ->
      expected =
        width: 100
        height: 100
      cropRect =
        x: 0
        y: 0
        width: 100
        height: 100
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()
      rect.send cropRect
      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer

    it 'should extract a buffer with cropping area on center', (done) ->
      expected =
        width: 256
        height: 256
      cropRect =
        x: 128
        y: 128
        width: 256
        height: 256
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()
      rect.send cropRect
      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer

    it 'should extract a buffer with cropping area being original dimensions', (done) ->
      expected =
        width: 512
        height: 512
      cropRect =
        x: 0
        y: 0
        width: 512
        height: 512
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(meta.height).to.be.equal expected.height
          done()
      rect.send cropRect
      testutils.getBuffer __dirname + '/fixtures/lenna.png', (buffer) ->
        ins.send buffer
