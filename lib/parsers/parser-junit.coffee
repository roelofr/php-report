###
Reads JUnit XML output to get the tests that were run and get pass / fail /
error scores.

@author Roelof Roos (https://github.com/roelofr)
###

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
