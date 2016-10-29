###
JUnit node
Contains values of a JUnit test node, which is either a test case or a test
suite

@author Roelof Roos (https://github.com/roelofr)
###

XmlElement = require 'libxmljs/lib/element'

module.exports =
class JunitNode

    node: null

    name: null
    file: null
    time: null

    count:
        test: null
        assert: null
        fail: null
        error: null

    constructor: (node) ->
        unless node instanceof XmlElement and node.attr
            throw new TypeError "Expected a XML node, got #{typeof node}"

        # Assign node
        @node = node

        # Get attributes
        @name = node.attr('name')?.value()
        @file = node.attr('file')?.value()
        @time = node.attr('time')?.value()

        # Get counts
        @count.test = node.attr('tests')?.value()
        @count.assert = node.attr('assertions')?.value()
        @count.fail = node.attr('failures')?.value()
        @count.error = node.attr('errors')?.value()

    getNode: ->
        return @node

    getName: ->
        return @name

    getFile: ->
        return @file

    getTime: ->
        return @time

    getTestCount: ->
        return @count.test

    getAssertCount: ->
        return @count.assert

    getFailCount: ->
        return @count.fail

    getErrorCount: ->
        return @count.error

    hasFailed: ->
        return Boolean(@node.get('*[descendant::failure]') || @node.get('failure'))

    hasError: ->
        return Boolean(@node.get('*[descendant::error]') || @node.get('error'))
