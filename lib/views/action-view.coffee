###
PHP Report
Action View
Contains buttons that do stuff

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'space-pen'

module.exports =
class ActionView extends View
    @buttons:
        btn_run: ['run', 'primary', 'playback-play', 'Start'],
        btn_kill: ['kill', 'default', 'flame', 'Abort'],
        btn_clear: ['clear', 'default', 'trashcan', null]

    @content: ->
        @div class: 'php-report__actions', outlet: 'elem_actions', =>
            @div class: 'block pull-right', =>
                for outlet, data of @buttons
                    config =
                        'data-click': data[0],
                        outlet: outlet,
                        class: "btn btn-#{data[1]} icon icon-#{data[2]} inline-block"

                    if data[3]
                        @button config, data[3]
                    else
                        @button config

    reporter: null

    initialize: (phpReport) ->
        @reporter = phpReport

        @btn_run.on('click', -> phpReport.runnerStart())
        @btn_kill.on('click', -> phpReport.runnerStop())
        @btn_clear.on('click', -> phpReport.trigger 'clean')

        phpReport.on('start', => @changeButtons yes)
        phpReport.on('stop', => @changeButtons no)
        @changeButtons no

    clear: ->
        @reporter.clear()

    changeButtons: (active) ->
        unless active
            @btn_run.removeAttr('disabled')
            @btn_clear.removeAttr('disabled')

            @btn_kill.attr('disabled', 'disabled')
        else
            @btn_run.attr('disabled', 'disabled')
            @btn_clear.attr('disabled', 'disabled')

            @btn_kill.removeAttr('disabled')
