#
# Reads PHPUnit config to derrive the name
# @author https://github.com/roelofr
# @license MIT
#

ParserXml = require './parser-xml'

TestCase = require '../models/junit-testcase'
TestSuite = require '../models/junit-testsuite'
TestGroup = require '../models/junit-testgroup'

module.exports =
class ParserJunit extends ParserXml

    getTestGroups: ->
        data = @getConfigData()

        if !data
            return null


        groups = []
        suites = data.root().childNodes();

        console.log 'Read finished!', suites

        # Get all suites that are supposed to run
        for suite in suites
            groups.push(new TestGroup(suite))

        return groups
