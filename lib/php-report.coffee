###
PHP Report
Main class, called by Atom

Although one should wonder if this isn't too much logic for an initiator...

@author Roelof Roos (https://github.com/roelofr)
###

# Required project dependancies
PhpReportView = require './php-report-view'
ParserPhpunit = require './parsers/parser-phpunit'
ParserJunit = require './parsers/parser-junit'
ParserClover = require './parsers/parser-clover'
Runner = require './runner'

# Required Atom dependancies
{CompositeDisposable, Emitter} = require 'atom'
path = require 'path'
fs = require 'fs'

# Constants
PHP_REPORT_URI = 'php-report://report'
CMD_TOGGLE = 'php-report:toggle'

hooks = {}
runner = null
view = null
emitter = new Emitter

module.exports = phpReport =

    activate: (state) ->
        # Register command that toggles this view
        atom.commands.add 'atom-workspace', CMD_TOGGLE, => @toggleView()

        # Register atom hooks
        atom.project.onDidChangePaths => @readConfig()

        # Create a PHPUnit runner
        runner = new Runner this

        # Bind hooks
        @on 'stop', => @testComplete()

        # Return nothing
        return

    deactivate: ->
        # Release all hooks
        emitter.clear()

        # Destroy runner
        runner.stop()
        runner = null

        # Return nothing
        return

    toggleView: ->
        unless view and view.active
            view = new PhpReportView this
            pane = atom.workspace.getActivePane()
            item = pane.addItem view, 0

            pane.activateItem item

            view.clear()
            @readConfig()
        else
            containingPane = atom.workspace.panelForItem(view)

            if containingPane
                containingPane.destroyItem view

            view = null

    setTitle: (title, subtitle) ->
        if view and view.active
            view.elem_header.setTitle(title)
            view.elem_header.setSubtitle(subtitle)

    readConfig: ->
        root = atom.project.getPaths()
        if root.length == 0
            console.warn "Cannot find root"
            return

        exists = (file) ->
            filePath = path.join(root[0], file)
            try
                fileStat = fs.statSync(filePath)
                return fileStat && fileStat.isFile()
            return false

        parser = new ParserPhpunit
        parser.getSuiteNames (names) =>
            if names == null
                @setTitle 'No test suites loaded', ''
                return

            data =
                main: null,
                side: null,
                list: names,
                available: false

            if names.length > 0
                data.available = true
                data.main = names.shift()
                if names.length == 1
                    data.side = "and #{names[0]}"
                else if names.length > 1
                    data.side = "and #{names.length} other test suites"

            @trigger 'config-update', data

    runnerStart: ->
        runner.start() if runner

    runnerStop: ->
        runner.stop() if runner

    testComplete: ->
        return unless runner
        resultTest = runner.getResultFile()
        resultCover = runner.getCoverageFile()
        if not resultTest or not resultCover
            console.warn 'Got no result file!'
            return


        clover = new ParserClover resultCover
        parser = new ParserJunit resultTest

        clover.getCoveragePercentage (coverage) =>
            if coverage == null then return
            @trigger 'update-metrics', coverage: coverage

        parser.getStatistics (data) =>
            if data == null then return
            @trigger 'update-metrics', data

        parser.getTestResults (data) =>
            if data == null then return
            console.log "Retrieved results of #{data.length} rows!"
            @trigger 'results', data

    # Do we really need to write our own hook system?

    ###
    Adds an event listener to the hook specified

    @param {String} name Hook to bind to
    @param {Function} action Action to perform
    ###
    on: (name, action) ->
        if typeof name != 'string' then return
        if typeof action != 'function' then return

        newAction = (data) ->
            action null, data

        emitter.on name, newAction

    ###
    Removes an action from the event listener, or removes all actions from an
    event.

    @param {String} name Hook name
    @param {Function|null} action Action to remove, or null to remove all
    ###
    off: (name, action = null) ->
        if typeof name != 'string' then return
        if typeof action != 'function' and action != null then return

        # If action is null, remove all elements
        if action == null then return hooks[name] = []

        # Else, only slice one off
        index = hooks[name].indexOf action
        hooks[name].splice(index, 1) if index != -1

    ###
    Triggers a hook, won't throw an error if nothing is bound to it.

    @param {String} hook Hook to call
    @param {Object} data Extra data to send
    ###
    trigger: (hook, data = {}) ->
        emitter.emit hook, data
