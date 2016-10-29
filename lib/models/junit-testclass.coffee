###
Contains a test suite that contains tests

@author Roelof Roos (https://github.com/roelofr)
###

JUnitNode = require './junit-node'
Test = require './junit-test'

module.exports =
class TestClass extends JUnitNode

    tests: null

    constructor: (node) ->
        super node

        tests = []
        for test in node.find '*[self::testcase or self::testsuite]'
            tests.push(new Test test)

        @tests = tests

    getTests: ->
        return @tests
