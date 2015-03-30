noflo = require 'noflo'
sharp = require 'sharp'
Canvas = require('noflo-canvas').canvas

# @runtime noflo-nodejs
# @name Resize

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Resize a given image to the new dimension'

  c.inPorts.add 'path',
    datatype: 'string'
    description: 'Path to image to be resized'
  c.inPorts.add 'width',
    datatype: 'integer'
    description: 'New width'
    required: false
  c.inPorts.add 'height',
    datatype: 'integer'
    description: 'New height'
    required: false
  c.outPorts.add 'canvas',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['path']
    params: ['width', 'height']
    out: ['canvas']
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    width = c.params.width
    height = c.params.height
    if not width? and not height?
      width = 256
    path = payload
    try
      inputBuffer = sharp path
      inputBuffer.metadata (err, metadata) ->
        if err
          return callback err
        inputBuffer
        .resize width, height
        .withMetadata()
        .withoutEnlargement()
        .toFormat 'png'
        .toBuffer (err, outputBuffer, info) ->
          if err
            return callback err
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
          do callback
    catch err
      return callback err

  c
