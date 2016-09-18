PhpunitReporterView = require './phpunit-reporter-view'
{CompositeDisposable} = require 'atom'

module.exports = PhpunitReporter =
  phpunitReporterView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @phpunitReporterView = new PhpunitReporterView(state.phpunitReporterViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @phpunitReporterView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'phpunit-reporter:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @phpunitReporterView.destroy()

  serialize: ->
    phpunitReporterViewState: @phpunitReporterView.serialize()

  toggle: ->
    console.log 'PhpunitReporter was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
