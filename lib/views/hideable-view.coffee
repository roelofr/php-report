###
PHP Report
A rather simple hideable view

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'space-pen'

module.exports =
class HideableView extends View
    hide: ->
        @addClass 'hidden'

    show: ->
        @removeClass 'hidden'
