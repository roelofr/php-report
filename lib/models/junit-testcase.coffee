#
# TestCase
# Contains values of a test case. May be part of a TestSuite
#

JUnitNode = require './junit-node'

module.exports =
class TestCase extends JUnitNode

    suite: null

    constructor: (node, suite = null) ->
        super node
        @suite = suite

    getTestSuite: ->
        return @suite
