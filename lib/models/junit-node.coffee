###
JUnit node
Contains values of a JUnit test node, which is either a test case or a test
suite

@author Roelof Roos (https://github.com/roelofr)
###

module.exports =
class JunitNode

    node: null

    name: null
    testCount: null
    assertCount: null
    failCount: null
    errorCount: null
    failure: null
    error: null

    constructor: (node) ->
        @node = node

        if !node.attr
            throw new TypeError("Expected a XML node, got #{typeof node}")

        # Get attributes
        @name = node.attr('name')
        @testCount = node.attr('tests')
        @assertCount = node.attr('assertions')
        @failCount = node.attr('failures')
        @errorCount = node.attr('errors')
        @time = node.attr('time')

        # Get failure, if any
        fail = node.get('//failure')
        if fail != null
            @failure = node.text()

        err = node.get('//error')
        if err != null
            @error = err.text()

    getName: ->
        return @name

    getTestCount: ->
        return @testCount

    getAssertCount: ->
        return @assertCount

    getFailCount: ->
        return @failCount

    getErrorCount: ->
        return @errorCount

    getTime: ->
        return @time

    getFailureMessage: ->
        return @failure

    getErrorMessage: ->
        return @error
