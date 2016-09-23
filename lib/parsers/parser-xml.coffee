###
Handles parsing XML files. Uses LibXMLjs for this, since it's written in C and
therefore significantly faster than a pure-js implementation (and there is more
strict type binding and more sugar and spice)

@author Roelof Roos (https://github.com/roelofr)
###
fs = require 'fs'
tmp = require 'tmp'
libxmljs = require 'libxmljs'

module.exports =
class ParserXml

    configFile: null
    configData: null

    read: (file, complete) ->
        if typeof file != 'string'
            throw new TypeError("File must be a string, got #{typeof file}.")

        @configFile = file
        fs.readFile @configFile, (err, data) =>
            @configData = libxmljs.parseXml(data)
            if complete and typeof complete == 'function'
                complete()

        return true

    getConfigFile: ->
        return @configFile

    getConfigData: ->
        return @configData
