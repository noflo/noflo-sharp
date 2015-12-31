noflo = require 'noflo'
sharp = require 'sharp'
path = require 'path'

# @runtime noflo-nodejs
# @name Resize

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Resize a given image file to the new dimension'

  c.inPorts.add 'in',
    datatype: 'all'
    description: 'Path to image file or image buffer to be resized'
  c.inPorts.add 'width',
    datatype: 'integer'
    description: 'New width'
    required: false
  c.inPorts.add 'height',
    datatype: 'integer'
    description: 'New height'
    required: false

  c.outPorts.add 'out',
    datatype: 'all'
    description: 'Resized buffer'
  c.outPorts.add 'factor',
    datatype: 'number'
    description: 'Original over resized dimensions factor'
    required: false
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['in']
    params: ['width', 'height']
    out: ['out', 'factor']
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    if (not Buffer.isBuffer payload) and (typeof payload isnt 'string')
      return callback Error 'Input is not a valid buffer nor image path'
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
            out.out.send outputBuffer
            out.factor.send factor
            do callback
        else
          inputBuffer
          .resize width, height
          .withMetadata()
          .withoutEnlargement()
          .toFormat 'png'
          .toBuffer (err, outputBuffer, info) ->
            if err
              return callback err
            originalWidth = metadata.width
            resizedWidth = info.width
            factor = originalWidth / resizedWidth
            out.out.send outputBuffer
            out.factor.send factor
            do callback
    catch err
      return callback err

  c
