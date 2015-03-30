noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Resize = require '../components/Resize-node.coffee'
  testutils = require './testutils'
else
  Resize = require 'noflo-sharp/components/Resize.js'
  testutils = require 'noflo-image/spec/testutils.js'

describe 'Resize component', ->
  c = null
  ins = null
  width = null
  height = null
  out = null
  beforeEach ->
    c = Resize.getComponent()
    ins = noflo.internalSocket.createSocket()
    width = noflo.internalSocket.createSocket()
    height = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.path.attach ins
    c.inPorts.width.attach width
    c.inPorts.height.attach height
    c.outPorts.canvas.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.path).to.be.an 'object'
      chai.expect(c.inPorts.width).to.be.an 'object'
      chai.expect(c.inPorts.height).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.canvas).to.be.an 'object'

  describe 'when passed an image', ->
    original =
      width: 512
      height: 512
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 128
        height: 256
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.height).to.be.equal expected.height
        chai.expect(data.originalWidth).to.be.equal original.width
        chai.expect(data.originalHeight).to.be.equal original.height
        done()

      width.send expected.width
      height.send expected.height
      ins.send __dirname + '/fixtures/lenna.png'

    it 'should resize it right when given just width', (done) ->
      expected =
        width: 128
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.height).to.be.equal expected.width
        chai.expect(data.originalWidth).to.be.equal original.width
        chai.expect(data.originalHeight).to.be.equal original.height
        done()

      width.send expected.width
      ins.send __dirname + '/fixtures/lenna.png'

    it 'should resize it right when given just height', (done) ->
      expected =
        height: 128
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.height
        chai.expect(data.height).to.be.equal expected.height
        chai.expect(data.originalWidth).to.be.equal original.width
        chai.expect(data.originalHeight).to.be.equal original.height
        done()

      height.send expected.height
      ins.send __dirname + '/fixtures/lenna.png'

    it 'should resize it right to default dimension', (done) ->
      expected =
        width: 256
        height: 256
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.height).to.be.equal expected.height
        chai.expect(data.originalWidth).to.be.equal original.width
        chai.expect(data.originalHeight).to.be.equal original.height
        done()

      ins.send __dirname + '/fixtures/lenna.png'

    it 'should not resize up (just down, without enlargement)', (done) ->
      expected =
        width: 512
        height: 512
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.height).to.be.equal expected.height
        chai.expect(data.originalWidth).to.be.equal original.width
        chai.expect(data.originalHeight).to.be.equal original.height
        chai.expect(data.width).to.be.equal data.originalWidth
        chai.expect(data.height).to.be.equal data.originalHeight
        done()

      width.send 1024
      ins.send __dirname + '/fixtures/lenna.png'

  describe 'when passed a GIF', ->
    original =
      width: 500
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 256
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.originalWidth).to.be.equal original.width
        done()

      width.send expected.width
      ins.send __dirname + '/fixtures/foo.gif'

  describe 'when passed a JPG', ->
    original =
      width: 2048
      height: 1536
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 1024
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.originalWidth).to.be.equal original.width
        done()

      width.send expected.width
      ins.send __dirname + '/fixtures/foo.jpeg'

  describe 'when passed a WEBP', ->
    original =
      width: 550
      height: 404
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 256
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.originalWidth).to.be.equal original.width
        done()

      width.send expected.width
      ins.send __dirname + '/fixtures/foo.webp'

  describe 'when passed a TIFF', ->
    original =
      width: 1076
      height: 750
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 256
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.originalWidth).to.be.equal original.width
        done()

      width.send expected.width
      ins.send __dirname + '/fixtures/foo.tif'
