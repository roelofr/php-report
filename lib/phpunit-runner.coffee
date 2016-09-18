#
# Derrived from phpunit atom package
# @author https://github.com/alairock
# @link https://github.com/alairock/phpunit-atom/blob/master/lib/phpunit.coffee
# @license MIT
#
fs = require 'fs'
tmp = require 'tmp'

module.exports =
class PhpunitRunner

    phpunit: null
    terminal: null

    events:
        start: null
        cancelled: null
        complete: null

    files:
        result: null,
        coverage: null

    constructor: (terminal) ->
        @terminal = terminal

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
        if @phpunit and @phpunit.pid then return

        # Get temp files
        tempFiles = {
            result: tmp.tmpNameSync()
            coverage: tmp.tmpNameSync()
        }

        console.log "Using #{tempFiles.result} as result file"
        console.log "Using #{tempFiles.coverage} as coverage file"

        # Switch buttons on terminal
        @terminal.buttonKill.enable()
        @terminal.buttonRun.disable()

        if @events.start != null
            try @events.start()

        projectPath = atom.project.getPaths()[0]
        options =
            cwd: projectPath
        spawn = require('child_process').spawn
        exec = 'phpunit' # TODO replace this with something configurable
        params = [
            "--log-junit=#{tempFiles.result}",
            "--coverage-xml=#{tempFiles.coverage}",
        ]

        console.log "> #{exec} #{params.join(' ')}"

        @phpunit = spawn exec, params, options

        @phpunit.stdout.on 'data', (data) =>
            @terminal.append data

        @phpunit.stderr.on 'data', (data) =>
            @terminal.append '<br><b>Runtime error</b><br><br>'
            @terminal.append data

        @phpunit.on 'close', (code, signal) =>
            if signal
                log = "Process killed with signal #{signal}"
            else
                log = 'Complete.'
            @terminal.append "<br>#{log}<br><hr>", false

            # Assign new files
            @files.result = tempFiles.result
            @files.coverage = tempFiles.coverage

            # Switch buttons again
            @terminal.buttonKill.disable()
            @terminal.buttonRun.enable()

            if signal and @events.cancelled != null
                try
                    @events.cancelled()
                catch ex
                    console.warn 'Error when handling cancelled event', ex
            else if signal
                console.warn 'Got no event for cancelled'

            if !signal and @events.complete != null
                try
                    @events.complete()
                catch ex
                    console.warn 'Error when handling complete event', ex
            else if !signal
                console.warn 'Got no event for complete'


    stop: ->
        if @phpunit.pid == null
            return

        @terminal.append 'Killing current PHPUnit execution...<br>'
        @phpunit.kill 'SIGHUP'
