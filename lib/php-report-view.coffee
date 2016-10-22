###
PHP Report view
Main view for the plugin

@author Roelof Roos (https://github.com/roelofr)
###
{View} = require 'atom-space-pen-views'
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
            @subview 'elem_idle', new IdleView

            @subview 'elem_term', new Terminal phpReport

    phpReport: null
    initialize: (phpReport) ->
        console.log 'PhpReportView: initialize'
        @phpReport = phpReport
        @active = true
        return

    destroy: ->
        console.log 'PhpReportView: destroy'
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

    setCommand: (command, action) ->
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
        @elem_term.append data