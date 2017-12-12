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
    describe "for a constant", ->
      beforeEach ->
        waitsForPromise ->
          activationPromise

        editor.insertText """
          class UndocumentedClass
            FANCY_CONSTANT = :foo
            def undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end
        """
        editor.getLastCursor().setBufferPosition([1,0])
        atom.commands.dispatch workspaceElement, 'yard:create'

      it "writes a default YARD doc", ->
        expected_output = """
          class UndocumentedClass
            FANCY_CONSTANT = :foo # Description of FANCY_CONSTANT
            def undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end
        """
        output = buffer.getText()
        expect(output).toContain(expected_output)

    describe "for a class", ->
      beforeEach ->
        waitsForPromise ->
          activationPromise

        editor.insertText """
          class UndocumentedClass
            def undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end
        """
        editor.getLastCursor().setBufferPosition([0,0])
        atom.commands.dispatch workspaceElement, 'yard:create'

      it "writes a default YARD doc", ->
        expected_output = """
          # Description of UndocumentedClass
          class UndocumentedClass
            def undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end
        """
        output = buffer.getText()
        expect(output).toContain(expected_output)

    describe "for a module", ->
      beforeEach ->
        waitsForPromise ->
          activationPromise

        editor.insertText """
          module UndocumentedModule
            class UndocumentedClass
              def undocumented_method(param1, param2=3)
                'The method is not documented!'
              end
            end
          end
        """
        editor.getLastCursor().setBufferPosition([0,0])
        atom.commands.dispatch workspaceElement, 'yard:create'

      it "writes a default YARD doc", ->
        expected_output = """
          # Description of UndocumentedModule
          module UndocumentedModule
            class UndocumentedClass
              def undocumented_method(param1, param2=3)
                'The method is not documented!'
              end
            end
          end
        """
        output = buffer.getText()
        expect(output).toContain(expected_output)

    describe "for class method", ->
      beforeEach ->
        waitsForPromise ->
          activationPromise

        editor.insertText """
          class UndocumentedClass
            def self.undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end
        """
        editor.getLastCursor().setBufferPosition([2,0])
        atom.commands.dispatch workspaceElement, 'yard:create'

      it "writes a default YARD doc", ->
        expected_output = """
          class UndocumentedClass
            # Description of .undocumented_method
            #
            # @param [Type] param1 describe_param1_here
            # @param [Type] param2 default: 3
            # @return [Type] description_of_returned_object
            def self.undocumented_method(param1, param2=3)
              'The method is not documented!'
            end
          end
        """
        output = buffer.getText()
        expect(output).toContain(expected_output)

    describe "for multiline method", ->
      beforeEach ->
        waitsForPromise ->
          activationPromise

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
        expected_output = """
          class UndocumentedClass
            # Description of #undocumented_multiline_method
            #
            # @param [Type] param1 describe_param1_here
            # @param [Type] param2 default: 3
            # @param [Type] opts default: {}
            # @return [Type] description_of_returned_object
            def undocumented_multiline_method(param1, param2 = 3, opts = {})
              'Not documented!'
              'Noot documented!'
              'Noooot documented!!!'
            end
          end
        """
        output = buffer.getText()
        expect(output).toContain(expected_output)

  # (Is it a feature or a bug? You decide)
  describe "when the yard:create event is triggered multiple times, from the bottom of the page", ->
    beforeEach ->
      waitsForPromise ->
        activationPromise

      editor.insertText """
        class UndocumentedClass

          def undocumented_method(param1, param2=3)
            'The method is not documented!'
          end

          def another_undocumented_method(param1)
            'The method is not documented!'
          end
        end
      """
      editor.getLastCursor().setBufferPosition([10,0])
      atom.commands.dispatch workspaceElement, 'yard:create'
      atom.commands.dispatch workspaceElement, 'yard:create'
      atom.commands.dispatch workspaceElement, 'yard:create'

    it "writes a default YARD doc", ->
      expected_output = """
        # Description of UndocumentedClass
        class UndocumentedClass

          # Description of #undocumented_method
          #
          # @param [Type] param1 describe_param1_here
          # @param [Type] param2 default: 3
          # @return [Type] description_of_returned_object
          def undocumented_method(param1, param2=3)
            'The method is not documented!'
          end

          # Description of #another_undocumented_method
          #
          # @param [Type] param1 describe_param1_here
          # @return [Type] description_of_returned_object
          def another_undocumented_method(param1)
            'The method is not documented!'
          end
        end
      """
      output = buffer.getText()
      expect(output).toContain(expected_output)
