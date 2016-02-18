noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Resize = require '../components/Resize-node.coffee'
  testutils = require './testutils'
  sharp = require 'sharp'
else
  Resize = require 'noflo-sharp/components/Resize.js'
  testutils = require 'noflo-image/spec/testutils.js'

describe 'Resize component', ->
  c = null
  ins = null
  width = null
  height = null
  metadata = null
  error = null
  out = null
  beforeEach ->
    c = Resize.getComponent()
    ins = noflo.internalSocket.createSocket()
    width = noflo.internalSocket.createSocket()
    height = noflo.internalSocket.createSocket()
    metadata = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.path.attach ins
    c.inPorts.width.attach width
    c.inPorts.height.attach height
    c.outPorts.metadata.attach metadata
    c.outPorts.error.attach error
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.path).to.be.an 'object'
      chai.expect(c.inPorts.width).to.be.an 'object'
      chai.expect(c.inPorts.height).to.be.an 'object'
    it 'should have output ports', ->
      chai.expect(c.outPorts.metadata).to.be.an 'object'
      chai.expect(c.outPorts.out).to.be.an 'object'
    it 'should have error port', ->
      chai.expect(c.outPorts.error).to.be.an 'object'

  describe 'when passed an image buffer', ->
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

    it 'should extract the right metadata', (done) ->
      original =
        width: 2048
        height: 1536
      resized =
        width: 128
        height: 256
      metadata.on 'data', (data) ->
        chai.expect(data.format).to.be.equal 'jpeg'
        chai.expect(data.exif).to.exists
        chai.expect(data.width).to.be.equal original.width
        chai.expect(data.height).to.be.equal original.height
        chai.expect(data.resizedWidth).to.be.equal resized.width
        chai.expect(data.resizedHeight).to.be.equal resized.height
        chai.expect(data.factor).to.be.equal original.width / resized.width
        done()

      width.send resized.width
      height.send resized.height
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
        width: c.defaultDimension
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          done()

      testutils.getBuffer __dirname + '/fixtures/foo.jpeg', (buffer) ->
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

  describe 'when passed a path to image file', ->
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
      ins.send  __dirname + '/fixtures/foo.jpeg'

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
      ins.send __dirname + '/fixtures/lenna.png'

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
      ins.send __dirname + '/fixtures/lenna.png'

    it 'should resize it right to default dimension', (done) ->
      expected =
        width: c.defaultDimension
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          done()

      ins.send __dirname + '/fixtures/foo.jpeg'

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
      ins.send __dirname + '/fixtures/lenna.png'

  describe 'when passed a missing image file', ->
    it 'should error', (done) ->
      error.on 'data', (data) ->
        err = Error 'Input file is of an unsupported image format'
        chai.expect(data).to.be.eql err
        done()
      ins.send  __dirname + '/fixtures/do-not-exist.jpeg'

  describe 'when passed an invalid image file', ->
    it 'should error', (done) ->
      error.on 'data', (data) ->
        err = Error 'Input file is of an unsupported image format'
        chai.expect(data).to.be.eql err
        done()
      ins.send  __dirname + '/Resize.coffee'

  describe 'when passed an invalid buffer', ->
    it 'should error', (done) ->
      error.on 'data', (data) ->
        err = Error 'Input file is of an unsupported image format'
        chai.expect(data).to.be.eql err
        done()
      testutils.getBuffer __dirname + '/Resize.coffee', (buffer) ->
        ins.send buffer

  describe 'when passed a narrow image with default values', ->
    it 'should resize to (? x default height)', (done) ->
      original =
        width: 736
        height: 7337
      expected =
        height: c.defaultDimension
      calculatedFactor = null
      metadata.on 'data', (data) ->
        calculatedFactor = data.factor
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.height).to.be.equal expected.height
          chai.expect(calculatedFactor).to.be.equal original.height / expected.height
          done()

      testutils.getBuffer __dirname + '/fixtures/narrow.jpg', (buffer) ->
        ins.send buffer

  describe 'when passed a wide image with default values', ->
    it 'should resize to (default width x ?)', (done) ->
      original =
        width: 7337
        height: 736
      expected =
        width: c.defaultDimension
      calculatedFactor = null
      metadata.on 'data', (data) ->
        calculatedFactor = data.factor
      out.on 'data', (data) ->
        buffer = sharp data
        buffer.metadata (err, meta) ->
          chai.expect(meta.width).to.be.equal expected.width
          chai.expect(calculatedFactor).to.be.equal original.width / expected.width
          done()

      testutils.getBuffer __dirname + '/fixtures/wide.jpg', (buffer) ->
        ins.send buffer

  describe 'when passed a GIF buffer', ->
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

  describe 'when passed a path to GIF file', ->
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
      ins.send __dirname + '/fixtures/foo.gif'

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

  describe 'when passed a path to JPG file', ->
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
      ins.send __dirname + '/fixtures/foo.jpeg'

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

  describe.skip 'when passed a path to WEBP file', ->
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
      ins.send __dirname + '/fixtures/foo.webp'

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

  describe 'when passed a path to TIFF file', ->
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
      ins.send __dirname + '/fixtures/foo.tif'
