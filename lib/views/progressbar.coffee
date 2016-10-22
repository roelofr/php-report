###
PHP Report
indeterminate progress bar, according to Material Design

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'atom-space-pen-views'

module.exports =

class Progressbar extends View

    @content: ->
        @div class: 'php-report__progress', =>
            @div class: 'php-report__progress-inner', =>
                @span class: 'indeterminate'


    initialize: (phpReport) ->
        phpReport.on('phpunit:start', => @show())
        phpReport.on('phpunit:stop', => @hide())

    hide: ->
        @addClass 'php-report__progress--hidden'

    show: ->
        @removeClass 'php-report__progress--hidden'
