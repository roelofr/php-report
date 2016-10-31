###
PHP Report
Terminal
Contains raw output from the PHPUnit command

@author Roelof Roos (https://github.com/roelofr)
###

HideableView = require './hideable-view'

module.exports =
class Terminal extends HideableView
    @content: ->
        @div class: 'php-report__terminal', =>
            @div class: 'inset-panel', =>
                @div class: 'panel-heading', outlet: 'header', 'Console output'
                @div class: 'panel-body php-report__terminal-panel', outlet: 'panel', =>
                    @pre class: 'php-report__terminal-inner', outlet: 'terminal'

    termContainer: null

    initialize: (phpReport) ->
        phpReport.on 'log', (line) => @append line
        phpReport.on 'clean', => @clear()

        @panel.addClass('hidden')
        @header.on 'click', => @panel.toggleClass('hidden')

    clear: ->
        @terminal.text ''
        @panel.scrollTop 0

    append: (text) ->
        if not text or typeof text != 'string' then return

        text = String(text).replace /(\r\n|\n\r|\r|\n)/g, '<br />$1'
        # Append text and scroll to end
        @terminal.append text
        @terminal.scrollTop @terminal.get(0).scrollHeight;
