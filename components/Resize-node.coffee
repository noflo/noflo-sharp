noflo = require 'noflo'
sharp = require 'sharp'
Canvas = require('noflo-canvas').canvas

# @runtime noflo-nodejs
# @name Resize

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Resize a given image'

  c.inPorts.add 'path',
    datatype: 'string'
    description: 'Path to image to be resized'
  c.inPorts.add 'width',
    datatype: 'integer'
    description: 'New width'
  c.inPorts.add 'height',
    datatype: 'integer'
    description: 'New height'

  c.outPorts.add 'canvas',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['path']
    params: ['width', 'height']
    out: ['canvas']
    forwardGroups: true
  , (payload, groups, out) ->
    width = if c.params.width? then c.params.width else null
    height = if c.params.height? then c.params.height else null
    if width is null and height is null
      width = 256
    path = payload
    try
      inputBuffer = sharp path
      inputBuffer.metadata (err, metadata) ->
        if err
          throw err
        inputBuffer
        .resize width, height
        .withMetadata()
        .toBuffer (err, outputBuffer, info) ->
          if err
            throw err
          # Create image with buffer as src
          image = new Canvas.Image
          image.src = outputBuffer
          # Create a host canvas and draw on it
          canvas = new Canvas(info.width, info.height)
          ctx = canvas.getContext '2d'
          ctx.drawImage image, 0, 0, info.width, info.height
          canvas.originalWidth = metadata.width
          canvas.originalHeight = metadata.height
          out.send canvas
    catch err
      out.error err

  c
