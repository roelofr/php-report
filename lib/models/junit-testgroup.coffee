#
# TestCase
# Contains values of a test case. May be part of a TestSuite
#

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
            if testNode.name() == 'testcase' then
                groupNodes.push(new TestCase(testNode))
            else if testNode.name() == 'testsuite' then
                groupNodes.push(new TestSuite(testNode))

        @testNodes = groupNodes

    getNodes: ->
        return @testNodes
