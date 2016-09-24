###
Reads JUnit XML output to get the tests that were run and get pass / fail /
error scores.

@author Roelof Roos (https://github.com/roelofr)
###

path = require 'path'
fs = require 'fs'
libxmljs = require 'libxmljs'

TestCase = require '../models/junit-testcase'
TestSuite = require '../models/junit-testsuite'
TestGroup = require '../models/junit-testgroup'

module.exports =
class ParserJunit

    dataFile: null
    dataContent: null

    constructor: (file) ->
        if typeof file != 'string'
            throw new TypeError("Expected file to be a string, not a #{typeof file}")

        try
            fileStat = fs.statSync(file)
            if fileStat and filestat.isFile()
                @dataFile = file

    ###
    Reads the config file if it hasn't been done already.

    @param {Function} callback `func(error, data)`
    @return {Boolean} true if reading, false if reading isn't possible
    @visibility private
    ###
    _read: (callback) ->
        if typeof callback != 'function' then return false
        if @configFile == null then return false

        if @configContent != null
            callback(null, @configContent)
            return true

        fs.readFile @configFile, 'utf8', (err, data) =>
            if err
                callback(err, null)
            else
                @configContent = data
                @configData = libxmljs.parseXml(data)
                callback(null, @configData)

        return true

    ###
    Async method to get the result from a JUnit result file

    @param {Function} callback `callback(data)` Returns TestGroup models
    ###
    getTestGroups: (callback) ->
        return if typeof callback != 'function'
        if @configFile == null
            callback(null)
            return

        readCallback = (ok, data) =>
            if !ok
                console.warn "Failed to read data!"
                return callback(null)

            groups = []
            suites = data.root().childNodes();

            console.log 'Read finished!', suites

            # Get all suites that are supposed to run
            for suite in suites
                groups.push new TestGroup(suite)

            return callback(groups)
