###
Reads PHPUnit config to derrive the name

@author Roelof Roos (https://github.com/roelofr)
###

path = require 'path'
fs = require 'fs'
ParserBase = require './parser-base'

module.exports =
class ParserPhpunit extends ParserBase

    configFile: null
    configContent: null
    configData: null

    constructor: ->
        # Find the first project that has a PHPUnit descriptor
        projects = atom.project.getPaths()
        filenames = ['phpunit.xml', 'phpunit.xml.dist']

        # Speed up a bit by pre-defining code for a loop
        exists = (base, file) ->
            filePath = path.join(base, file)
            try
                fileStat = fs.statSync(filePath)
                return fileStat && fileStat.isFile()
            return false

        # Loop through projects, checking each filename for each project
        for project in projects
            for filename in filenames
                unless exists(project, filename)
                    continue
                @configFile = path.join(project, filename)
                break
            if @configFile != null then break

        # Make sure we have  config

        if @configFile == null
            console.warn 'No valid config file was found'
            return

        console.log "Found #{@configFile}. Not reading until needed"

    ###
    Reads the config file if it hasn't been done already.

    @param {Function} callback `func(error, data)`
    @return {Boolean} true if reading, false if reading isn't possible
    @visibility private
    ###
    read: (callback) ->
        if typeof callback != 'function' then return false
        if @configFile == null then return false

        if @configContent != null
            callback null, @configContent
            return true

        super @configFile, (err, data) =>
            if err
                callback err, null
            else
                @configContent = data
                callback null, @configContent

    ###
    Reads the suite names from the PHPUnit config

    @param {Function} callback after read has completed
    @return array List of suite names. Null on error
    ###
    getSuiteNames: (callback) ->
        return if typeof callback != 'function'
        if @configFile == null
            console.warn 'ConfigFile is null!'
            callback(null)
            return

        readCallback = (err, data) =>
            if err != null
                console.warn "Failed to read data:", err
                return callback(null)
            names = []

            # Get all suites that are supposed to run
            for suite in data.find('//testsuites/testsuite')
                if suite.attr('name')
                    console.log "Read #{suite.attr('name').value()}"
                    names.push(suite.attr('name').value())

            callback(names)

        # Read, report if the read method returns false
        unless @read readCallback
            callback(null)

    ###
    Async method to get the name of the test suite(s)

    @param {Function} callback `callback(names)`
    @return {String}
    ###
    getSuiteName: (callback) ->
        @getSuiteNames (names) =>
            if names == null
                return callback(null)

            if names.length > 1
                last2 = names.pop()
                last1 = names.pop()
                names.push("#{last1} and #{last2}")

            return callback(names.join(', '))
