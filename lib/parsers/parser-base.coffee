###
Base for a config reader

@author Roelof Roos (https://github.com/roelofr)
###

fs = require 'fs'
libxmljs = require 'libxmljs'

module.exports =
class ParserBase

    ###
    Reads a file, parses the XML and returns the result.

    @param {String} file
    @param {Function} callback The callback, arg1 = xml, arg2 = error
    ###
    read: (file, callback) ->
        # Make sure callbacks are valid
        if typeof callback != 'function' then return false
        if typeof file != 'string' then return false

        # Read the file, async
        fs.readFile file, 'utf8', (err, content) =>
            if err
                # Report error and return it
                console.error "Reading #{file} failed:", err
                callback err, null
            else
                # Parse XML and return it
                data = libxmljs.parseXml content
                callback null, data
