###
TestCase
Contains values of a test case. May be part of a TestSuite

@author Roelof Roos (https://github.com/roelofr)
###

JUnitNode = require './junit-node'
TestCase = require './junit-testcase'
TestSuite = require './junit-testsuite'

module.exports =
class TestGroup extends JUnitNode

    testNodes: null

    constructor: (node) ->
        super node

        groupNodes = []

        for testNode in node.childNodes()
            if testNode.name() == 'testcase'
                groupNodes.push(new TestCase(testNode))
            else if testNode.name() == 'testsuite'
                groupNodes.push(new TestSuite(testNode))

        @testNodes = groupNodes

    getNodes: ->
        return @testNodes
