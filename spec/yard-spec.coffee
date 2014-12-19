Yard = require '../lib/yard'

describe "Yard", ->
  [workspaceElement, activationPromise, editor, buffer] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('yard')
    # Open a sample Ruby class file
    waitsForPromise ->
      atom.workspace.open('sample.rb').then (o) ->
        editor = o
        buffer = editor.buffer


  describe "when the yard:create event is triggered", ->
    it "writes a default YARD doc for single line method", ->
      expected_output = """class UndocumentedClass
                             # Description of method
                             #
                             # @param param1 [Symbol] description of param1, and possible examples
                             # @return [String] description of returned object
                             def undocumented_method
                               'The method is not documented!'
                             end

                             def undocumented_multiline_method
                               'Not documented!'
                               'Noot documented!'
                               'Noooot documented!!!'
                             end
                           end
                           """

      editor.getLastCursor().setBufferPosition([2,0])
      atom.commands.dispatch workspaceElement, 'yard:create'
      output = buffer.getText()
      expect(output).toContain(expected_output)

    it "writes a default YARD doc for multiline method", ->
      expected_output = """class UndocumentedClass
                             def undocumented_method
                               'The method is not documented!'
                             end

                             # Description of method
                             #
                             # @param param1 [Symbol] description of param1, and possible examples
                             # @return [String] description of returned object
                             def undocumented_multiline_method
                               'Not documented!'
                               'Noot documented!'
                               'Noooot documented!!!'
                             end
                           end
                           """

      editor.getLastCursor().setBufferPosition([9,0])
      atom.commands.dispatch workspaceElement, 'yard:create'
      output = buffer.getText()
      expect(output).toContain(expected_output)
