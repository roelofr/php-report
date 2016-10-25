###
PHP Report result-entry
A model for a single result entry, which is a View element

@author Roelof Roos (https://github.com/roelofr)
###
{View} = require 'space-pen'

module.exports =

class TestResultSingle extends View
    @content: ->
        @div class: 'php-report-result', outlet: 'container', =>
            @div class: 'php-report-result__header php-report-result-header', outlet: 'header' =>
                @div class: 'php-report-result-header__icon', outlet: 'icon'
                @div class: 'php-report-result-header__title', =>
                    @h4 outlet: 'title', =>
                        @span()
                    @span class: 'php-report-result-header__title-class', outlet: 'header_class'
                    @span class: 'php-report-result-header__title-test', outlet: 'header_test'
                @div class: 'php-report-result-header__stats', =>
                    @div class: 'php-report-result-header__stat', =>
                        @
            @button click: 'clear', class: 'btn btn-default pull-right', =>
                @span class: 'icon icon-trashcan'
                @span "Dismiss"
            @button click: 'run', class: 'btn btn-default pull-right', outlet: 'buttonRun', =>
                @span class: 'icon icon-playback-play'
                @span "Restart"
            @button click: 'kill', class: 'btn btn-default pull-right', outlet: 'buttonKill', enabled: false, =>
                @span class: 'icon icon-stop'
                @span "Abort"
            @div class: 'phpunit-contents', outlet: 'output', style: 'font-family: monospace'

    clear: ->
        @output.html ""

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

    copy: ->
        atom.clipboard.write @output.text()

    append: (data, parse = true) ->
        breakTag = "<br>"
        data = data + ""
        if parse
            data = data.replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            data = data.replace /\son line\s(\d+)/g, ":$1"
            data = data.replace /((([A-Z]\\:)?([\\/]+(\w|-|_|\.)+)+(\.(\w|-|_)+)+(:\d+)?))/g, "<a>$1</a>"

        @output.append data
