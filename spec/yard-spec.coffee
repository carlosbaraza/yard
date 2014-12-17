Yard = require '../lib/yard'

describe "Yard", ->
  [workspaceElement, activationPromise, editor] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('yard')
    # Open a sample Ruby class file
    waitsForPromise ->
      atom.workspace.open('sample.rb', initialLine: 1).then (o) -> editor = o

  describe "when the yard:create event is triggered", ->
    it "writes a default YARD doc string at current cursor position", ->
      buffer = editor.buffer
      atom.commands.dispatch workspaceElement, 'yard:create'

      expect(buffer.getText()).toContain """
        # Description of method
        #
        # @param param1 [Symbol] description of param1, and possible examples
        # @return [String] description of returned object\n
      """
