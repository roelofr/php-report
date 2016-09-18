#
# Reads PHPUnit config to derrive the name
# @author https://github.com/roelofr
# @license MIT
#
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
