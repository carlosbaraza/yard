{CompositeDisposable} = require 'atom'
Snippets = require atom.packages.resolvePackagePath('snippets') + '/lib/snippets.js'

module.exports = Yard =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "yard:create", => @create()

  create: ->
    editor = atom.workspace.getActivePaneItem()
    cursor = editor.getLastCursor()
    editor.transact =>
      prevDefRow = @findStartRow(editor, cursor)
      params = @parseMethodLine(editor.lineTextForBufferRow(prevDefRow))
      snippet_string = @buildSnippetString(params)
      @insertSnippet(editor, cursor, prevDefRow, snippet_string)

  findStartRow: (editor, cursor) ->
    row = cursor.getBufferRow()
    while (editor.buffer.lines[row].indexOf('def ') == -1)
      break if row == 0
      row -= 1
    row

  insertSnippet: (editor, cursor, prevDefRow, snippet_string) ->
    cursor.setBufferPosition([prevDefRow,0])
    editor.moveToFirstCharacterOfLine()
    indentation = cursor.getIndentLevel()
    editor.insertNewlineAbove()
    editor.setIndentationForBufferRow(cursor.getBufferRow(), indentation)
    Snippets.insert(snippet_string)

  buildSnippetString: (params) ->
    snippet_string = "# ${1:Description of method}\n#\n"
    index = 2
    for param in params
      snippet_string += "# @param [${#{index}:Type}] #{param} ${#{index + 1}:describe #{param}}\n"
      index += 2
    snippet_string += "# @return [${#{index}:Type}] ${#{index + 1}:description of returned object}"
    snippet_string

  parseMethodLine: (methodLine) ->
    opened_bracket = methodLine.indexOf("(")
    closed_bracket = methodLine.indexOf(")")
    return [] if opened_bracket == -1 and closed_bracket == -1
    params_string = methodLine.substring(opened_bracket + 1, closed_bracket)
    params_string.split(',').map((m) -> m.trim())
