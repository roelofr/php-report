###
Reads PHPUnit test results to determine the coverage percentage.

@author Roelof Roos (https://github.com/roelofr)
###

path = require 'path'
fs = require 'fs'
ParserBase = require './parser-base'

module.exports =
class ParserClover extends ParserBase

    resultFile: null
    resultData: null

    constructor: (file) ->
        if typeof file != 'string'
            console.warn 'Tried to use non-string as file!', file
            return

        # Always make sure the file exists and is a file!
        try
            fileStat = fs.statSync file

            # Log non-files to the console
            if fileStat and fileStat.isFile()
                @resultFile = file
            else
                console.warn "Tried to use non-existent or non-file #{file}!"

        catch err
            # Log errors!
            console.warn "Failed to read file #{file}: ", err
            return

    ###
    Reads the config file if it hasn't been done already.

    @param {Function} callback `func(error, data)`
    @return {Boolean} true if reading, false if reading isn't possible
    @visibility private
    ###
    read: (callback) ->
        if typeof callback != 'function' then return false
        if @resultFile == null then return false

        if @resultData != null
            callback null, @resultData
            return true

        super @resultFile, (err, data) =>
            if err
                callback err, null
            else
                @resultData = data
                callback null, @resultData

    ###
    Reads the test results and returns a test coverage percentage

    @param {Function} callback after read has completed
    @return array List of suite names. Null on error
    ###
    getCoveragePercentage: (callback) ->
        if typeof callback != 'function' then return false

        @read (err, data) =>
            if err != null
                console.warn "Failed to read data:", err
                return callback null

            coveredCode = 0
            totalCode = 0

            # Find all metrics and calculate coverage
            for metric in data.find '//project/metrics'
                if metric.attr 'coveredelements'
                    totalCode += Number metric.attr('elements').value()
                    coveredCode += Number metric.attr('coveredelements').value()
                else if metric.attr 'coveredstatements'
                    totalCode += Number metric.attr('statements').value()
                    coveredCode += Number metric.attr('coveredstatements').value()

            if coveredCode == 0 or totalCode == 0
                callback 0
            else
                callback coveredCode / totalCode * 100
