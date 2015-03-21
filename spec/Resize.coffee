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
    it 'should resize it to the specified dimension', (done) ->
      expected =
        width: 128
        height: 256
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.width).to.be.equal expected.width
        chai.expect(data.height).to.be.equal expected.height
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
        done()

      ins.send __dirname + '/fixtures/lenna.png'