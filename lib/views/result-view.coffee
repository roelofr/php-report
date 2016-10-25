###
PHP Report
Result View
Contains test results

@author Roelof Roos (https://github.com/roelofr)
###

HideableView = require './hideable-view'

module.exports =
class ResultView extends HideableView
    @content: ->
        @div class: 'php-report__results'

    initialize: (phpReport) ->
        phpReport.on 'phpunit:clean', => @clear()

    clear: ->
        # Does nothing
