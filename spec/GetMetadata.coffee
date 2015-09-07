noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetMetadata = require '../components/GetMetadata.coffee'
  testutils = require './testutils'
  sharp = require 'sharp'
else
  GetMetadata = require 'noflo-sharp/components/GetMetadata.js'
  testutils = require 'noflo-image/spec/testutils.js'

outports = [
  'format'
  'width'
  'height'
  'space'
  'channels'
  'profile'
  'alpha'
  'orientation'
  'exif'
  'icc'
]

describe 'GetMetadata component', ->
  c = null
  ins = null
  outs = []
  beforeEach ->
    c = GetMetadata.getComponent()
    ins = noflo.internalSocket.createSocket()
    c.inPorts.buffer.attach ins
    for outport in outports
      outs[outport] = noflo.internalSocket.createSocket()
      c.outPorts[outport].attach outs[outport]

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.buffer).to.be.an 'object'
    it 'should have an output port', ->
      for outport in outports
        chai.expect(c.outPorts[outport]).to.be.an 'object'

  describe 'when passed an image buffer', ->
    @timeout 10000
    it 'should extract all possible metadata', ->
      expected =
        format: 'jpeg'
        width: 2048
        height: 1536
        space: 'srgb'
        channels: 3
        profile: null
        alpha: null
        orientation: 1
        icc: null
      outs.format.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.format
      outs.width.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.width
      outs.height.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.height
      outs.space.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.space
      outs.channels.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.channels
      outs.profile.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.profile
      outs.alpha.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.alpha
      outs.orientation.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.orientation
      outs.exif.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data).to.be.instanceof Buffer
      outs.icc.on 'data', (data) ->
        chai.expect(data).to.be.equal expected.icc
      testutils.getBuffer __dirname + '/fixtures/foo.jpeg', (buffer) ->
        ins.send buffer
