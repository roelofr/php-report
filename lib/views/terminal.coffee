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
            @pre class: 'php-report__terminal-inner', outlet: 'term'

    termContainer: null

    initialize: (phpReport) ->
        @termContainer = @term.parent()
        phpReport.on 'phpunit:log', (event) => @append event.detail

    clear: ->
        @term.text ''
        @termContainer.scrollTop 0

    append: (text) ->
        text = String(text).replace /(\r\n|\n\r|\r|\n)/g, '<br />$1'
        # Append text
        @term.append text

        # Scroll to end
        @termContainer.scrollTop @termContainer.get(0).scrollHeight;
