###
Contains a testsuite, which contains testCases

@author Roelof Roos (https://github.com/roelofr)
###

JUnitNode = require './junit-node'
TestCase = require './junit-testcase'

module.exports =
class TestSuite extends JUnitNode

    testCases: null

    constructor: (node) ->
        super node

        if !node.testCase then return

        cases = [];
        for testcase of node.children()
            if testcase.name() == 'testcase'
                cases.push(new TestCase(testcase, this))

        @testCases = cases

    getCases: ->
        return @testCases
