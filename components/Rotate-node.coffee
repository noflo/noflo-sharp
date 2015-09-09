noflo = require 'noflo'
sharp = require 'sharp'
Canvas = require('noflo-canvas').canvas

# @runtime noflo-nodejs
# @name Rotate

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Rotate a given image buffer to a new angle'

  c.inPorts.add 'buffer',
    datatype: 'object'
    description: 'Image to be resized'
  c.inPorts.add 'angle',
    datatype: 'number'
    description: 'New angle'
    required: false
  c.outPorts.add 'buffer',
    datatype: 'object'
  c.outPorts.add 'angle',
    datatype: 'number'
    required: false
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['buffer']
    params: ['angle']
    out: ['buffer', 'angle']
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    {angle} = c.params
    inputBuffer = sharp payload
    if angle is null
      # Rotate based on EXIF
      inputBuffer.metadata (err, metadata) ->
        exifOrientation = metadata.orientation
        angle = switch exifOrientation
          when 1 then 0
          when 3 then 180
          when 6 then 90
          when 8 then 270
          else 0
        try
          inputBuffer
          .rotate(angle)
          .withMetadata()
          .toFormat 'png'
          .toBuffer (err, outputBuffer, info) ->
            if err
              return callback err
            out.buffer.send outputBuffer
            out.angle.send angle
            do callback
        catch err
          return callback err
    else
      # Rotate based on user defined angle
      try
        inputBuffer
        .rotate(angle)
        .withMetadata()
        .toFormat 'png'
        .toBuffer (err, outputBuffer, info) ->
          if err
            return callback err
          out.angle.send angle
          out.buffer.send outputBuffer
          do callback
      catch err
        return callback err

  c
