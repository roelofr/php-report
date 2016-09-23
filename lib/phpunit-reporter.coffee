###
PHPUnit Reporter
Main class, called by Atom

Although one should wonder if this isn't too much logic for an initiator...

@author Roelof Roos (https://github.com/roelofr)
###
PhpunitReporterView = require './phpunit-reporter-view'
ParserPhpunit = require './parsers/parser-phpunit'
ParserJunit = require './parsers/parser-junit'
PhpunitRunner = require './phpunit-runner'

path = require 'path'
fs = require 'fs'
{CompositeDisposable} = require 'atom'

module.exports = PhpunitReporter =

    phpunitReporterView: null
    modalPanel: null
    runner: null

    activate: (state) ->

        console.log 'Hello world!'

        @phpunitReporterView = new PhpunitReporterView(state.phpunitReporterViewState)
        @modalPanel = atom.workspace.addBottomPanel(
            item: @phpunitReporterView
        )

        @runner = new PhpunitRunner(@phpunitReporterView)
        @runner.setComplete(=> @testComplete())

        @phpunitReporterView.setCommand('run', => @start())
        @phpunitReporterView.setCommand('kill', => @stop())
        @phpunitReporterView.setCommand('close', => @hide())

        # Register command that toggles this view
        atom.commands.add 'atom-workspace', 'phpunit-reporter:toggle': => @toggle()
        atom.commands.add 'atom-workspace', 'phpunit-reporter:start': => @start()
        atom.commands.add 'atom-workspace', 'phpunit-reporter:stop': => @stop()

        @toggle()
        @readConfig()

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


        # Find the phpunit file
        if exists('phpunit.xml')
            config = path.join(root[0], 'phpunit.xml')
        else if exists('phpunit.xml.dist')
            config = path.join(root[0], 'phpunit.xml.dist')
        else
            console.warn "No config file found in #{root[0]}."
            return

        parser = new ParserPhpunit
        parser.read config, =>
            console.log "Reading #{config} finished"
            console.log parser.getSuiteName()

    deactivate: ->
        @modalPanel.destroy()
        @phpunitReporterView.destroy()

    serialize: ->
        phpunitReporterViewState: @phpunitReporterView.serialize()

    start: ->
        @show
        @runner.start()

    stop: ->
        @runner.stop

    testComplete: ->
        resultFile = @runner.getResultFile()
        if !resultFile
            console.warn 'Got no result file!'
            return

        console.log "Starting read of #{resultFile}"

        parser = new ParserJunit
        parser.read resultFile, =>
            console.log "Reading stuff finished!"
            console.log "The result is as follows:", parser.getTestGroups()

    show: ->
        if !@modalPanel.isVisible()
            @modalPanel.show()
            console.log 'Showing'

    hide: ->
        if @modalPanel.isVisible()
            @modalPanel.hide()
            console.log 'Hiding'

    toggle: ->
        console.log 'PhpunitReporter was toggled!'

        if @modalPanel.isVisible()
          @hide()
        else
          @show()
