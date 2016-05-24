noflo = require 'noflo'
sharp = require 'sharp'

# @runtime noflo-nodejs
# @name Extract

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Extract a region from a given image buffer'

  # TODO: It could be any datatype and if object, buffer, if string, path
  c.inPorts.add 'buffer',
    datatype: 'object'
    description: 'Image to be extracted'
    required: true
  c.inPorts.add 'rect',
    datatype: 'object'
    description: 'A rectangle'
    required: true
  c.outPorts.add 'buffer',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: 'buffer'
    params: 'rect'
    out: 'buffer'
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    {rect} = c.params
    buffer = payload
    bbox =
      left: rect.x
      top: rect.y
      width: rect.width
      height: rect.height
    try
      inputBuffer = sharp buffer
      inputBuffer.metadata (err, metadata) ->
        inputBuffer
        .extract(bbox)
        .withMetadata()
        .toFormat 'png'
        .toBuffer (err, outputBuffer, info) ->
          if err
            return callback err
          out.send outputBuffer
          do callback
    catch err
      return callback err

  c
