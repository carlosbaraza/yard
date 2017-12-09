{CompositeDisposable} = require 'atom'
Snippets = require atom.packages.resolvePackagePath('snippets') + '/lib/snippets.js'

module.exports = Yard =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "yard:create", => @create()

  create: ->
    editor = atom.workspace.getActivePaneItem()
    cursor = editor.getLastCursor()
    editor.transact =>
      {rowNumber, definitionType} = @findStartRow(editor, cursor)
      if !definitionType then return

      params = @parseMethodLine(editor.lineTextForBufferRow(rowNumber))
      snippet_string = @buildSnippetString(params, definitionType)
      @insertSnippet(editor, cursor, rowNumber, snippet_string)

  findStartRow: (editor, cursor) ->
    output = { rowNumber: 0, definitionType: '' }
    editor.moveToEndOfLine()
    scanStart = cursor.getBufferPosition()
    endScan = [0,0]
    editor.backwardsScanInBufferRange /(def|class|module)\s(self)?/, [scanStart, endScan], (element) =>
      output.definitionType = if element.match[1] is 'def'
        "#{if element.match[2] is 'self' then 'class ' else ''}method"
      else
        element.match[1]
      output.rowNumber = element.range.end.row
      element.stop()
    output

  insertSnippet: (editor, cursor, prevDefRow, snippet_string) ->
    cursor.setBufferPosition([prevDefRow,0])
    editor.moveToFirstCharacterOfLine()
    indentation = cursor.getIndentLevel()
    editor.insertNewlineAbove()
    editor.setIndentationForBufferRow(cursor.getBufferRow(), indentation)
    Snippets.insert(snippet_string)

  buildSnippetString: (params, definitionType) ->
    snippet_string = "# ${1:Description of #{definitionType}}\n#"

    if definitionType.match /method/
      index = 2
      for param in params
        cleanParam = param.replace(':', '')
        snippet_string += "\n# @param [${#{index}:Type}] #{cleanParam} ${#{index + 1}:describe_#{cleanParam}}"
        index += 2

      snippet_string += "\n# @return [${#{index}:Type}] ${#{index + 1}:description of returned object}"
    snippet_string

  parseMethodLine: (methodLine) ->
    opened_bracket = methodLine.indexOf("(")
    closed_bracket = methodLine.indexOf(")")
    return [] if opened_bracket == -1 and closed_bracket == -1
    params_string = methodLine.substring(opened_bracket + 1, closed_bracket)
    params_string.split(',').map((m) -> m.trim())
