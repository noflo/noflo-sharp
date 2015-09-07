noflo = require 'noflo'
sharp = require 'sharp'
Canvas = require('noflo-canvas').canvas

# @runtime noflo-nodejs
# @name ResizeBuffer

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Resize a given image buffer to a new dimension'

  c.inPorts.add 'buffer',
    datatype: 'object'
    description: 'Image buffer to be resized'
  c.inPorts.add 'width',
    datatype: 'integer'
    description: 'New width'
    required: false
  c.inPorts.add 'height',
    datatype: 'integer'
    description: 'New height'
    required: false
  c.outPorts.add 'buffer',
    datatype: 'object'
  c.outPorts.add 'factor',
    datatype: 'number'
    required: false
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['buffer']
    params: ['width', 'height']
    out: ['buffer', 'factor']
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    width = c.params.width
    height = c.params.height
    if not width? and not height?
      width = 256
    try
      inputBuffer = sharp payload
      inputBuffer.metadata (err, metadata) ->
        if err
          return callback err
        # Try to preserve the same format, if there's EXIF
        if metadata.exif?
          inputBuffer
          .resize width, height
          .withMetadata()
          .withoutEnlargement()
          .toBuffer (err, outputBuffer, info) ->
            if err
              return callback err
            originalWidth = metadata.width
            resizedWidth = info.width
            factor = originalWidth / resizedWidth
            out.buffer.send outputBuffer
            out.factor.send factor
            do callback
        else
          inputBuffer
          .resize width, height
          .withMetadata()
          .withoutEnlargement()
          .toFormat('png')
          .toBuffer (err, outputBuffer, info) ->
            if err
              return callback err
            originalWidth = metadata.width
            resizedWidth = info.width
            factor = originalWidth / resizedWidth
            out.buffer.send outputBuffer
            out.factor.send factor
            do callback
    catch err
      return callback err

  c
