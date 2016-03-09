noflo = require 'noflo'
sharp = require 'sharp'

# @runtime noflo-nodejs
# @name GetMetadata

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'expand'
  c.description = 'Get metadata from a given image buffer'

  c.inPorts.add 'buffer',
    datatype: 'object'
    description: 'Image buffer'

  c.outPorts.add 'format',
    datatype: 'string'
    description: 'Name of decoder to be used to decompress image data e.g. jpeg, png, webp'
    required: false
  c.outPorts.add 'width',
    datatype: 'number'
    description: 'Number of pixels wide'
    required: false
  c.outPorts.add 'height',
    datatype: 'number'
    description: 'Number of pixels high'
    required: false
  c.outPorts.add 'space',
    datatype: 'string'
    description: 'Name of colour space interpretation e.g. srgb, rgb, scrgb, cmyk, lab, xyz, b-w ...'
    required: false
  c.outPorts.add 'channels',
    datatype: 'number'
    description: 'Number of bands (e.g. 3 for sRGB, 4 for CMYK)'
    required: false
  c.outPorts.add 'profile',
    datatype: 'boolean'
    description: 'Boolean indicating the presence of an embedded ICC profile'
    required: false
  c.outPorts.add 'alpha',
    datatype: 'boolean'
    description: 'Boolean indicating the presence of an alpha transparency channel'
    required: false
  c.outPorts.add 'orientation',
    datatype: 'number'
    description: 'Number value of the EXIF Orientation header, if present'
    required: false
  c.outPorts.add 'exif',
    datatype: 'object'
    description: 'Buffer containing raw EXIF data, if present'
    required: false
  c.outPorts.add 'icc',
    datatype: 'object'
    description: 'Buffer containing raw ICC profile data, if present'
    required: false

  noflo.helpers.WirePattern c,
    in: ['buffer']
    out: [
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
    async: true
    forwardGroups: true
  , (payload, groups, out, callback) ->
    inputBuffer = sharp payload
    try
      inputBuffer.metadata (err, metadata) ->
        if err
          return callback err
        keys = Object.keys out
        for key in keys
          if metadata[key]?
            out[key].send metadata[key]
          else
            out[key].send null
        do callback
    catch err
      return callback err

  c
