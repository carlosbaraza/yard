Yard = require '../lib/yard'

describe "Yard", ->
  [workspaceElement, activationPromise, editor, buffer] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('yard')
    # Open a sample Ruby class file
    waitsForPromise ->
      atom.workspace.open().then (o) ->
        editor = o
        buffer = editor.buffer

  describe "when the yard:create event is triggered", ->
    describe "for single line method", ->
      beforeEach ->
        editor.insertText """
          class UndocumentedClass
            def undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end

        """
        editor.getLastCursor().setBufferPosition([2,0])
        atom.commands.dispatch workspaceElement, 'yard:create'

      it "writes a default YARD doc", ->
        expected_output = """class UndocumentedClass
                               # Description of method
                               #
                               # @param [Type] param1 describe param1
                               # @param [Type] param2=3 describe param2=3
                               # @return [Type] description of returned object
                               def undocumented_method(param1, param2=3)
                                 'The method is not documented!'
                               end
                             end
                             """
        output = buffer.getText()
        expect(output).toContain(expected_output)

    describe "for multiline method", ->
      beforeEach ->
        editor.insertText """
          class UndocumentedClass
            def undocumented_multiline_method(param1, param2 = 3, opts = {})
              'Not documented!'
              'Noot documented!'
              'Noooot documented!!!'
            end
          end

        """
        editor.getLastCursor().setBufferPosition([4,0])
        atom.commands.dispatch workspaceElement, 'yard:create'

      it "writes a default YARD doc", ->
        expected_output = """class UndocumentedClass
                               # Description of method
                               #
                               # @param [Type] param1 describe param1
                               # @param [Type] param2 = 3 describe param2 = 3
                               # @param [Type] opts = {} describe opts = {}
                               # @return [Type] description of returned object
                               def undocumented_multiline_method(param1, param2 = 3, opts = {})
                                 'Not documented!'
                                 'Noot documented!'
                                 'Noooot documented!!!'
                               end
                             end
                             """
        output = buffer.getText()
        expect(output).toContain(expected_output)
