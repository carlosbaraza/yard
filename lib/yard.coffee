{CompositeDisposable} = require 'atom'

module.exports = Yard =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "yard:create", => @create()

  create: ->
    editor = atom.workspace.getActivePaneItem()
    cursor = editor.getLastCursor()
    editor.transact =>
      prevDefRow = @findStartRow(editor, cursor)
      cursor.setBufferPosition([prevDefRow,0])
      editor.moveToFirstCharacterOfLine()
      @insertSnippet(editor, cursor)

  findStartRow: (editor, cursor) ->
    row = cursor.getBufferRow()
    while (editor.buffer.lines[row].indexOf('def ') == -1)
      break if row == 0
      row -= 1
    row

  insertSnippet: (editor, cursor) ->
    indentation = cursor.getIndentLevel()
    editor.insertNewlineAbove()
    insertIndentedLine = (string) =>
      editor.setIndentationForBufferRow(cursor.getBufferRow(), indentation)
      editor.insertText("#{string}")
    insertIndentedLine("# Description of method\n")
    insertIndentedLine("#\n")
    insertIndentedLine("# @param param1 [Symbol] description of param1, and possible examples\n")
    insertIndentedLine("# @return [String] description of returned object")
