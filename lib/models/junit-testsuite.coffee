###
Contains a test suite which contains test classes

@author Roelof Roos (https://github.com/roelofr)
###

JUnitNode = require './junit-node'
TestClass = require './junit-testclass'

module.exports =
class TestSuite extends JUnitNode

    testClasses: null

    constructor: (node) ->
        super node

        classes = []
        for testclass in node.find 'testsuite'
            classes.push(new TestClass testclass)

        @testClasses = classes

        console.log this

    getClasses: ->
        return @testClasses
