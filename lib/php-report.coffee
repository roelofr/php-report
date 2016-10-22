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

    hookLinks: {}

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
            activeView = new PhpReportView this

            commandRunner = new Runner this
            commandRunner.setComplete(=> @testComplete())

            activePane = atom.workspace.getActivePane()
            newItem = activePane.addItem activeView
            activePane.activateItem(newItem)

            # Reset interface
            activeView.clear()

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

    setTitle: (title, subtitle) ->
        if activeView and activeView.active
            activeView.elem_header.setTitle(title)
            activeView.elem_header.setSubtitle(subtitle)

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
        parser.getSuiteNames (names) =>
            if names == null
                @setTitle 'No test suites loaded', ''
                return

            if activeView.elem_idle then activeView.elem_idle.setAvailability true

            if names.length == 1
                @setTitle names.pop(), ''
            else if names.length == 2
                @setTitle names.shift(), 'and ' + names.shift()
            else
                @setTitle names.shift(), 'and ' + names.length + ' other test suites.'

    deactivate: ->
        console.log 'PHP Report: deactivate'
        return

    runnerStart: ->
        unless activeView and activeView.active
            @toggleView
        return unless commandRunner
        commandRunner.start()

    runnerStop: ->
        return unless commandRunner
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

    # Do we really need to write our own hook system?
    ###
    Adds an event listener to the hook specified

    @param {String} name Hook to bind to
    @param {Function} action Action to perform
    ###
    on: (name, action) ->
        console.log 'Debug on!', typeof action, typeof name

        if typeof name != 'string' then return
        if typeof action != 'function' then return

        if not @hookLinks[name] then @hookLinks[name] = []
        @hookLinks[name].push(action)

    ###
    Removes an action from the event listener, or removes all actions from an
    event.

    @param {String} name Hook name
    @param {Function|null} action Action to remove, or null to remove all
    ###
    off: (name, action = null) ->
        if typeof name != 'string' then return
        if typeof action != 'function' and action != null then return

        if action == null
            @hookLinks[name] = []
        else
            newLinks = []
            for hook in @hookLinks[name]
                if hook != action then newLinks.push(action)

            @hookLinks[name] = newLinks

    ###
    Triggers a hook, won't throw an error if nothing is bound to it.

    @param {String} hook Hook to call
    @param {Object} data Extra data to send
    ###
    trigger: (hook, data = {}) ->
        console.log "Trigger #{hook} with #{data}."
        if not @hookLinks[hook] then return
        if @hookLinks[hook].length == 0 then return

        event = new CustomEvent hook, detail: data, cancelable: true
        for action in @hookLinks[hook]
            if event.defaultPrevented then break
            action event
