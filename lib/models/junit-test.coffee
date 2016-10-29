###
Contains a test, can be either a single test or a test with subcases (when
using a data provider, for example).

@author Roelof Roos (https://github.com/roelofr)
###

JUnitNode = require './junit-node'

module.exports =
class Test extends JUnitNode

    class: null
    line: null

    tests: null
    multiple: false

    msg:
        fail: null
        error: null

    constructor: (node) ->
        super node

        # Get proper name (method) and class
        if node.attr 'class'
            @class = node.attr('class').value()
        else if (commaPos = @name.indexOf '::') != -1
            @class = @name.substr 0, commaPos
            @name = @name.substr commaPos + 2

        # Test suites contain subtests, which we should flag
        @multiple = node.name() == 'testsuite'
        if @multiple
            @multiple = true

            tests = []
            for test in node.find 'testcase'
                tests.push(new Test test)

            @tests = tests

        # Get failure and error, if any
        @msg.fail = node.get('failure')?.text()
        @msg.error = node.get('error')?.text()

    isMultiple: ->
        return Boolean(@multiple)

    getTests: ->
        return @tests

    getClass: ->
        return @class

    getFailureMessage: ->
        return @msg.fail

    getErrorMessage: ->
        return @msg.error
