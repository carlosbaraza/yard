{CompositeDisposable} = require 'atom'

module.exports = Yard =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "yard:create", => @create()

  create: ->
    editor = atom.workspace.getActivePaneItem()
    editor.insertText("""
      # Description of method
      #
      # @param param1 [Symbol] description of param1, and possible examples
      # @return [String] description of returned object\n
    """)
