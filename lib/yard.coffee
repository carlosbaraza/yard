{CompositeDisposable} = require 'atom'
Snippets = require atom.packages.resolvePackagePath('snippets') + '/lib/snippets.js'

module.exports = Yard =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "yard:create", => @create()

  create: ->
    editor = atom.workspace.getActivePaneItem()
    cursor = editor.getLastCursor()
    editor.transact =>
      row = @parseStartRow(editor, cursor)
      if !row.type or @commentAlreadyExists(editor, row) then return

      comment = @buildComment(row)
      @insertSnippet(editor, cursor, row.number, comment)

  parseStartRow: (editor, cursor) ->
    row = { name: '', number: 0, params: '', type: '' }
    editor.moveToEndOfLine()
    scanStart = cursor.getBufferPosition()
    endScan = [0,0]
    regExp = /(def|class|module)\s(self)?(.?\w+)(\(.*\))?/
    editor.backwardsScanInBufferRange regExp, [scanStart, endScan], (element) =>
      row.params = element.match[4]
      row.number = element.range.end.row
      if element.match[1] is 'def'
        row.name = if element.match[2] is 'self' then element.match[3] else '#' + element.match[3]
        row.type = "#{if element.match[2] is 'self' then 'class ' else ''}method"
      else
        row.name = element.match[3]
        row.type = element.match[1]
      element.stop()
    row

  commentAlreadyExists: (editor, row) ->
    if row.number is 0
      return false
    else
      rowAbove = editor.lineTextForBufferRow(row.number - 1)
      if row.type.match(/method/)
        !!(rowAbove.match(/# @return/))
      else
        !!(rowAbove.match(/# /))

  insertSnippet: (editor, cursor, definitionRowNumber, comment) ->
    cursor.setBufferPosition([definitionRowNumber, 0])
    editor.moveToFirstCharacterOfLine()
    indentation = cursor.getIndentLevel()
    editor.insertNewlineAbove()
    editor.setIndentationForBufferRow(cursor.getBufferRow(), indentation)
    Snippets.insert(comment)

  buildComment: (row) ->
    params = @buildParams(row.params)
    comment = "# ${1:Description of #{row.name}}"

    if row.type.match /method/
      index = 1
      comment += "\n#"
      for param in params
        comment += "\n# @param [${#{index+=1}:Type}] #{param.argument} "
        postfix = if param.default
          "default: #{param.default}"
        else
          "describe_#{param.argument}_here"
        comment += "${#{index+=1}:#{postfix}}"
      comment += "\n# @return [${#{index+=1}:Type}] ${#{index+1}:description_of_returned_object}"

    comment

  buildParams: (paramString) =>
    if !paramString then return []
    paramsArray = paramString.replace(/\(|\)/g, '').split(',')
    for param in paramsArray
      paramMatch = param.match /(\w+)\s*([=:])?\s*(.+)?/
      { argument: paramMatch[1], default: paramMatch[2] && (paramMatch[3] || 'nil') }
