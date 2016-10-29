###
Derrived from the 'phpunit' atom package

I took some leads from https://github.com/alairock/phpunit-atom/blob/master/lib/phpunit.coffee,
but after I wrapped my head around the code, I just wrote it myself. The
previous header no longer applies, but I'm still putting in a thank-you for
Skyler Lewis <https://github.com/alairock>.

@author Roelof Roos (https://github.com/roelofr)
###
fs = require 'fs'
tmp = require 'tmp'

module.exports =
class PhpunitRunner

    phpunit: null
    phpReport: null

    events:
        start: null
        cancelled: null
        complete: null

    files:
        result: null,
        coverage: null

    constructor: (phpReport) ->
        @phpReport = phpReport

    getResultFile: ->
        return if @files.result != null then @files.result else null

    getCoverageFile: ->
        return if @files.coverage != null then @files.coverage else null

    setStart: (callback) ->
        if callback && typeof callback == 'function'
            @events.start = callback

    setComplete: (callback) ->
        if callback && typeof callback == 'function'
            @events.complete = callback

    setCancelled: (callback) ->
        if callback && typeof callback == 'function'
            @events.cancelled = callback

    cleanup: ->
        # Delete stale config files
        if @files.result != null and fs.exists(@files.result)
            try
                fs.unlink(@files.result)
        if @files.coverage != null and fs.exists(@files.coverage)
            try
                fs.unlink(@files.coverage)

        @files.result = null
        @files.coverage = null

    start: ->
        # One instance at a times
        if @phpunit and @phpunit.pid and @phpunit.connected
            console.warn "Process is still running as", @phpunit.pid
            return

        # Get temp files
        tempFiles = {
            result: tmp.tmpNameSync()
            coverage: tmp.tmpNameSync()
        }

        console.log "Using #{tempFiles.result} as result file"
        console.log "Using #{tempFiles.coverage} as coverage file"

        # Switch buttons on terminal
        @phpReport.trigger 'start'

        if @events.start != null
            try @events.start()

        projectPath = atom.project.getPaths()[0]
        options =
            cwd: projectPath
        spawn = require('child_process').spawn
        exec = 'phpunit' # TODO replace this with something configurable
        params = [
            "--log-junit=#{tempFiles.result}",
            "--coverage-clover=#{tempFiles.coverage}",
        ]

        @phpunit = spawn exec, params, options

        @phpunit.stdout.on 'data', (data) =>
            @phpReport.trigger 'log', data

        @phpunit.stderr.on 'data', (data) =>
            message = "<br><br><strong>Runtime error</strong><br><br>#{data}"
            @phpReport.trigger 'log', message

        @phpunit.on 'close', (code, signal) =>
            # Assign new files
            @files.result = tempFiles.result
            @files.coverage = tempFiles.coverage

            # Switch buttons again
            @phpReport.trigger 'stop', exitcode: signal

    stop: ->
        if @phpunit.pid == null
            return

        @phpReport.trigger 'log', '<span class="text-error icon icon-circle-slash"></span>'
        @phpunit.kill 'SIGTERM'
