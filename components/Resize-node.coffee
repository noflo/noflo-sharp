noflo = require 'noflo'
sharp = require 'sharp'
path = require 'path'

# @runtime noflo-nodejs
# @name Resize

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Resize a given image file to the new dimension'
  c.defaultDimension = 1024

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
  c.outPorts.add 'original',
    datatype: 'object'
    description: 'Original dimension'
    required: false
  c.outPorts.add 'resized',
    datatype: 'object'
    description: 'Resized dimension'
    required: false
  c.outPorts.add 'metadata',
    datatype: 'object'
    description: 'Extracted metadata while resizing'
    required: false
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['in']
    params: ['width', 'height']
    out: ['out', 'factor', 'original', 'resized', 'metadata']
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    if (not Buffer.isBuffer payload) and (typeof payload isnt 'string')
      return callback Error 'Input is not a valid buffer nor image path'
    width = c.params.width
    height = c.params.height
    try
      inputBuffer = sharp payload
      inputBuffer.metadata (err, metadata) ->
        if err
          return callback err
        # Default value when nothing is specified
        if not width? and not height?
          # Deal with narrow or wide images
          if metadata.width > metadata.height
            width = c.defaultDimension
          else
            height = c.defaultDimension
        format = if metadata.exif? then 'jpeg' else 'png'
        inputBuffer
        .resize width, height
        .withMetadata()
        .withoutEnlargement()
        .toFormat format
        .toBuffer (err, outputBuffer, info) ->
          if err
            return callback err
          if width
            originalWidth = metadata.width
            resizedWidth = info.width
            factor = originalWidth / resizedWidth
          else
            originalHeight = metadata.height
            resizedHeight = info.height
            factor = originalHeight / resizedHeight
          out.out.send outputBuffer
          out.factor.send factor
          out.original.send
            width: metadata.width
            height: metadata.height
          out.resized.send
            width: info.width
            height: info.height
          out.metadata.send metadata
          do callback
    catch err
      return callback err

  c
