###
PHP Report result-header
The header for the result page. Shows project name, run tests, failures, errors
and code coverage.

@author Roelof Roos (https://github.com/roelofr)
###

{View} = require 'space-pen'
HeaderScore = require './header-score';

module.exports =

class HeaderView extends View

    @content: ->
        @div class: 'php-report__header', outlet: 'container', =>
            @div class: 'php-report__header-brand', =>
                @span class: 'php-report__header-brand-title', outlet: 'title'
                @span class: 'php-report__header-brand-subtitle', outlet: 'subtitle'
            @div class: 'php-report__header-stats', =>
                @subview 'test_count', new HeaderScore('Tests', false)
                @subview 'fail_count', new HeaderScore('Failures', true)
                @subview 'err_count', new HeaderScore('Errors', true)
                @subview 'coverage', new HeaderScore('Coverage', false)

    initialize: (phpReport) ->
        phpReport.on 'config-update', (data) =>
            @setTitle data.main
            @setSubtitle data.side

        phpReport.on 'update-metrics', (data) =>

            if data.tests?
                @setTestCount data.tests

            if data.failures?
                @setFailureCount data.failures

            if data.errors?
                @setErrorCount data.errors

            if data.coverage?
                @setCoveragePercentage data.coverage

        phpReport.on 'clean', => @clear()

    clear: ->
        @test_count.setValue '0'
        @fail_count.setValue '0'
        @err_count.setValue '0'
        @coverage.setValue '0%'

    setTitle: (title) ->
        @title.text title

    setSubtitle: (title) ->
        @subtitle.text title

    setTestCount: (count) ->
        if typeof count != 'number' || count < 0
            count = 0
        @test_count.updateValue Math.floor(count)

    setFailureCount: (failure) ->
        if typeof failure != 'number' || failure < 0
            failure = 0
        @fail_count.updateValue Math.floor(failure)

    setErrorCount: (error) ->
        if typeof error != 'number' || error < 0
            error = 0
        @err_count.updateValue Math.floor(error)

    setCoveragePercentage: (coverage) ->
        if typeof coverage != 'number' || coverage < 0 || coverage > 100
            coverage = 0
        @coverage.updateValue "#{Math.floor coverage}%"
