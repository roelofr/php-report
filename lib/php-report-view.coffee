###
PHP Report view
Main view for the plugin

@author Roelof Roos (https://github.com/roelofr)
###
{View} = require 'space-pen'
HeaderView = require './views/header-view'
ActionView = require './views/action-view'
Progressbar = require './views/progressbar'
ResultView = require './views/result-view'
IdleView = require './views/idle-view'
Terminal = require './views/terminal'

module.exports =

class PhpReportView extends View

    @content: (phpReport) ->
        @div class: 'php-report', outlet: 'container', =>
            @subview 'elem_header', new HeaderView phpReport
            @subview 'elem_action', new ActionView phpReport

            @subview 'elem_progress', new Progressbar phpReport

            @subview 'elem_result', new ResultView phpReport
            @subview 'elem_idle', new IdleView phpReport

            @subview 'elem_term', new Terminal phpReport

    phpReport: null
    initialize: (phpReport) ->
        @phpReport = phpReport
        @active = true

        phpReport.on 'result-ready', => @showResults()
        phpReport.on 'clear', => @clear()

    destroy: ->
        @active = false
        return

    getTitle: ->
        return 'PHP Report'

    clear: ->
        @elem_term.clear()
        @elem_progress.hide()
        @elem_result.hide()
        @elem_idle.show()
        @elem_header.clear()

    showResults: ->
        @elem_idle.hide()
        @elem_result.show()

    setCommand: (command, action) ->
        if typeof command != 'string' then return
        if typeof action != 'function' then return

        @commands[command] = action

    kill: ->
        if @commands.kill
            @commands.kill()

    run: ->
        if @commands.run
            @commands.run()

    close: ->
        if @commands.close
            @commands.close()

    append: (data, parse = true) ->
        if not data? or typeof data != 'string' then return

        @elem_term.append data
