###
PHP Report
indeterminate progress bar, according to Material Design

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'space-pen'

module.exports =

class Progressbar extends View

    @content: ->
        @div class: 'php-report__progress', =>
            @div class: 'php-report__progress-inner', =>
                @span class: 'indeterminate'


    initialize: (phpReport) ->
        phpReport.on('start', => @show())
        phpReport.on('stop', => @hide())

    hide: ->
        @addClass 'php-report__progress--hidden'

    show: ->
        @removeClass 'php-report__progress--hidden'
