###
PHP Report result-header
The header for the result page. Shows project name, run tests, failures, errors
and code coverage.

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'atom-space-pen-views'

class HeaderScore extends View
    @content: (name) ->
        @div class: 'php-report-cell', =>
            @span class: 'php-report-counter', outlet: 'counter'
            @span class: 'text-subtle', outlet: 'label', name

    setValue: (value) ->
        @counter.text value

module.exports =

class HeaderView extends View

    @content: ->
        @div class: 'php-report-header row', outlet: 'container', =>
            @div class: 'php-report-cell php-report-cell--main', =>
                @span class: 'php-report-title', outlet: 'title', 'Hello World!'
            @subview 'test_count', new HeaderScore('Tests')
            @subview 'fail_count', new HeaderScore('Failures')
            @subview 'err_count', new HeaderScore('Errors')
            @subview 'coverage', new HeaderScore('Coverage')

    clear: ->
        @title.html 'No title'
        @test_count.setValue '0'
        @fail_count.setValue '0'
        @err_count.setValue '0'
        @coverage.setValue '0%'

    setTitle: (title) ->
        @title.text title

    setTestCount: (count) ->
        if typeof count != 'number' || count < 0
            count = 0
        @test_count.setValue Math.floor(count)

    setFailureCount: (failure) ->
        if typeof failure != 'number' || failure < 0
            failure = 0
        @fail_count.setValue Math.floor(failure)

    setErrorCount: (error) ->
        if typeof error != 'number' || error < 0
            error = 0
        @err_count.setValue Math.floor(error)

    setCoveragePercentage: (coverage) ->
        if typeof coverage != 'number' || coverage < 0 || coverage > 100
            coverage = 0
        @coverage.setValue "#{Math.floor coverage}%"
