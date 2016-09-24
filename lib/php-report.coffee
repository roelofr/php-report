###
PHP Report
Main class, called by Atom

Although one should wonder if this isn't too much logic for an initiator...

@author Roelof Roos (https://github.com/roelofr)
###
PhpReportView = require './php-report-view'
ParserPhpunit = require './parsers/parser-phpunit'
ParserJunit = require './parsers/parser-junit'
Runner = require './runner'

{CompositeDisposable} = require 'atom'
path = require 'path'
fs = require 'fs'

PHP_REPORT_URI = 'php-report://report'
commandRunner = null
activeView = null

module.exports = phpReport =

    activate: (state) ->
        console.log 'PHP Report: activate'

        # Register command that toggles this view
        atom.commands.add 'atom-workspace',
            'php-report:toggle': => @toggleView()
            'php-report:start': => @runnerStart()
            'php-report:stop': => @runnerStop()

    toggleView: ->
        console.log 'PHP Report: toggle'

        unless activeView and activeView.active
            activeView = new PhpReportView
            activeView.setCommand('run', => @runnerStart())
            activeView.setCommand('kill', => @runnerStop())
            activeView.setCommand('close', => @toggleView())

            commandRunner = new Runner(activeView)
            commandRunner.setComplete(=> @testComplete())

            activePane = atom.workspace.getActivePane()
            newItem = activePane.addItem activeView
            activePane.activateItem(newItem)

            # Reset interface
            activeView.header.clear()

            # Read content of interface
            @readConfig()
        else
            # Always cancel the runner
            commandRunner.stop()
            commandRunner = null

            containingPane = atom.workspace.panelForItem(activeView)

            if containingPane
                containingPane.destroyItem(activeView)

            activeView = null

    setTitle: (title) ->
        if activeView and activeView.active
            activeView.header.setTitle(title)

    readConfig: ->
        console.log 'PHP Report: readConfig'

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
        parser.getSuiteName (name) =>
            if name != null
                @setTitle name

    deactivate: ->
        console.log 'PHP Report: deactivate'
        return

    runnerStart: ->
        unless activeView and activeView.active
            @toggleView
        return if commandRunner
        commandRunner.start()

    runnerStop: ->
        return if commandRunner
        commandRunner.stop()

    testComplete: ->
        return if commandRunner
        resultFile = commandRunner.getResultFile()
        if !resultFile
            console.warn 'Got no result file!'
            return

        console.log "Starting read of #{resultFile}"

        parser = new ParserJunit(resultFile)
        parser.getTestGroups (groups) =>
            console.log "Reading stuff finished!"
            console.log "Resulting groups:", groups
