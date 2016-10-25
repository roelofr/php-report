###
PHP Report
HeaderScore
Contains a single metric and keeps track if they rise or fall.

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'space-pen'

module.exports =
class HeaderScore extends View
    ###
    @var {Boolean} Set to true if a rise of this value is considered bad.
                   Used, for example, on 'error' counters.
    ###
    isBadProperty: false

    @content: ->
        @div class: 'php-report__header-stat php-report-stat', =>
            @span class: 'php-report-stat__score', outlet: 'counter'
            @span class: 'php-report-stat__label-container', =>
                @span class: 'php-report-stat__icon icon', outlet: 'icon'
                @span class: 'php-report-stat__label', outlet: 'label', name

    initialize: (name, isBad) ->
        @label.text String(name)
        @isBadProperty = Boolean(isBad)
        @setValue 0

    ###
    Sets the new value of the counter, clearing the 'change' percentage

    @param {String} value
    ###
    setValue: (value) ->
        @counter.text value

        # Hide the icon
        @icon.addClass 'php-report-stat__icon--hidden'
        @icon.removeClass 'icon-primitive-square', 'icon-triangle-up', 'icon-triangle-down'

    ###
    Identical to setValue, but will also updat the 'change' to match the new
    value.

    @param {Float|String} value
    ###
    updateValue: (value) ->
        # Get new and current value, parseFloat removes "%" symbols
        curValue = parseFloat @counter.text()
        newValue = parseFloat value

        # Update value
        @counter.text value

        # If old value was 0, just set change to infinity.
        if curValue == 0 and newValue > 0
            changePerc = Infinity
        else
            changePerc = newValue / curValue - 1

        # Bad properties should lower, not rise
        changePerc *= -1 if @isBadProperty

        # Show icon and apply class
        @icon.removeClass 'php-report-stat__icon--hidden'
        @icon.toggleClass 'icon-primitive-square', changePerc == 0
        @icon.toggleClass 'icon-triangle-up', changePerc > 0
        @icon.toggleClass 'icon-triangle-down', changePerc < 0
