###
PHP Report
Result View
Contains test results

@author Roelof Roos (https://github.com/roelofr)
###

HideableView = require './hideable-view'

TestSuite = require '../models/junit-testsuite'
TestClass = require '../models/junit-testclass'
Test = require '../models/junit-test'

$ = require 'jquery'

module.exports =
class ResultView extends HideableView

    @phpReport: null

    @content: ->
        @div class: 'php-report__results php-report-results', =>
            @div class: 'block', outlet: 'resultContainer'

    initialize: (phpReport) ->
        @phpReport = phpReport

        @phpReport.on 'clean', => @clear()
        @phpReport.on 'results', (data) => @setResults data

    clear: ->
        @resultContainer.empty()

    getTitleSpan: (node) ->
        title = $('<span class="php-report-test" />')

        if node.hasError()
            title.addClass('php-report-test--error')
        else if node.hasFailed()
            title.addClass('php-report-test--fail')
        else
            title.addClass('php-report-test--pass')

        return title

    setResults: (results) ->
        if not results or typeof results != 'object' or not results.forEach
            console.warn 'Cannot read results!', results
            return

        @clear()

        for testSuite in results
            if testSuite instanceof TestSuite
                console.log "Reading test suite #{testSuite.getName()}..."
                @unpackTestSuite @resultContainer, testSuite
            else
                console.warn "Non-TestSuite type received!"
                console.log testSuite

        @phpReport.trigger 'result-ready'

    unpackTestSuite: (container, testSuite) ->

        buffer = $('<div class="padded" />')
        panel = $('<div class="inset-panel" />')
        header = $('<div class="panel-heading" />')
        body = $('<div class="panel-body padded" />')
        list = $('<ul class="list-tree" />')

        container.append buffer
        buffer.append panel
        panel.append header, body
        body.append list

        header.text testSuite.getName()

        for testClass in testSuite.getClasses()
            if testClass instanceof TestClass
                console.log "Reading test class #{testClass.getName()}..."
                @unpackTestClass list, testClass
            else
                console.warn "Non-TestClass type received!"
                console.log testClass

    unpackTestClass: (container, testClass) ->
        item = $('<li class="list-nested-item" />')
        header = $('<div class="list-item" />')
        title = @getTitleSpan testClass
        list = $('<ul class="list-tree" />')

        container.append item
        item.append header, list
        header.append title

        title.text testClass.getName()

        for testCase in testClass.getTests()
            if testCase instanceof Test
                if testCase.isMultiple()
                    @unpackTestGroup list, testCase
                else
                    @unpackTestSingle list, testCase
            else
                console.warn "Non-Test type received!"
                console.log testCase

    unpackTestSingle: (container, test) ->
        item = $('<li class="list-item" />')
        title = @getTitleSpan test

        container.append item
        item.append title

        title.text test.getName()

    unpackTestGroup: (container, test) ->
        item = $('<li class="list-nested-item" />')
        header = $('<div class="list-item" />')
        title = @getTitleSpan test
        list = $('<ul class="list-tree" />')
        className = $('<em />')
        method = $('<strong />')

        container.append item
        item.append header, list
        header.append title
        title.append className, method

        className.text "#{test.getClass()}::"
        method.text test.getName()

        for testCase in test.getTests()
            if testCase instanceof Test
                @unpackTestSingle list, testCase
            else
                console.warn "Non-Test type received!"
                console.log testCase
