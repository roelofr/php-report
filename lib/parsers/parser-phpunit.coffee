#
# Reads PHPUnit config to derrive the name
# @author https://github.com/roelofr
# @license MIT
#

ParserXml = require './parser-xml'

module.exports =
class ParserPhpunit extends ParserXml

    getSuiteName: ->
        if @getConfigData() == null
            return null

        data = @getConfigData()

        if !data.phpunit or !data.phpunit.testsuites
            console.warn 'Missing stuff here!'
            console.log data.phpunit
            return null

        names = []

        # Get all suites that are supposed to run
        for suite in data.get('//testsuites').childNodes
            if suite.attr('name')
                names.push(suite.attr('name').value())

        if names.length > 1
            last2 = names.pop()
            last1 = names.pop()
            names.push("#{last1} and #{last2}")

        return names.join(', ')
