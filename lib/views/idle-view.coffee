###
PHP Report
Idle View
Contains a "no tests run" message, or a message informing the user how to run
tests, if they haven't created a PHPUnit config yet.

@author Roelof Roos (https://github.com/roelofr)
###

HideableView = require './hideable-view'

unavailableBody = [
    """
    PHPUnit has not been configured for this project! You need to configure
    PHPUnit before you can use this plugin.
    """,
    """
    To configure PHPUnit, create a 'phpunit.xml.dist' file, containing the
    configuration for your project. Please see the PHPUnit documentation for
    further information on how to do this.
    """,
    """
    After updating the configuration, please re-open PHPReport to re-scan your
    projects.
    """
]

module.exports =
class IdleView extends HideableView
    @content: ->
        @div class: 'php-report__idle', =>
            @ul class: 'background-message centered', outlet: 'standby', =>
                @li 'No tests run, yet...'
            @tag 'atom-panel', class: 'padded', outlet: 'unavailable', =>
                @div class: 'inset-panel', =>
                    @div class: 'panel-heading', 'PHPUnit not configured'
                    @div class: 'panel-body padded', =>
                        @p unavailableBody[0]
                        @p unavailableBody[1]
                        @p unavailableBody[2]

    initialize: ->
        @setAvailability false
        @unavailable.find('.panel-body').html(unavailableBody)

    hide: ->
        @addClass 'hidden'

    show: ->
        @removeClass 'hidden'

    setAvailability: (available) ->
        if available
            @standby.removeClass 'hidden'
            @unavailable.addClass 'hidden'
        else
            @standby.addClass 'hidden'
            @unavailable.removeClass 'hidden'

    clear: ->
        # Does nothing
