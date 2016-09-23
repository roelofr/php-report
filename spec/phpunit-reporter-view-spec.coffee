###
Checks how life's doing, which is out of scope, I guess....?
###
PhpunitReporterView = require '../lib/phpunit-reporter-view'

describe "PhpunitReporterView", ->
  it "has one valid test", ->
    expect("life").toBe "easy"
