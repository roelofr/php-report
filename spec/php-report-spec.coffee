###
Checks the plugin, note that this test is left as-is since the plugin was
created and therefore does not represent features the plugin /should// have.
###
PhpReport = require '../lib/php-report'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "PhpReport", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('php-report')

  describe "when the php-report:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.php-report')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'php-report:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.php-report')).toExist()

        phpunitReporterElement = workspaceElement.querySelector('.php-report')
        expect(phpunitReporterElement).toExist()

        phpunitReporterPanel = atom.workspace.panelForItem(phpunitReporterElement)
        expect(phpunitReporterPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'php-report:toggle'
        expect(phpunitReporterPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.php-report')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'php-report:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        phpunitReporterElement = workspaceElement.querySelector('.php-report')
        expect(phpunitReporterElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'php-report:toggle'
        expect(phpunitReporterElement).not.toBeVisible()
