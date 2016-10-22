###
PHP Report result-entry
A model for a single result entry, which is a View element

@author Roelof Roos (https://github.com/roelofr)
###
{View} = require 'atom-space-pen-views'

module.exports =

class EntryView extends View
    # Internal: Build up the HTML contents for the fragment.
    commands: {
        run: null
        kill: null
        close: null
    }

    @content: ->
        @div class: 'phpunit-container', outlet: 'container', =>
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
