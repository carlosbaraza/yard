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
      @insertSnippet(editor, cursor, row.number, comment, (row.type isnt 'constant'))

  parseStartRow: (editor, cursor) ->
    row = { name: '', number: 0, params: '', type: '' }
    editor.moveToEndOfLine()
    scanStart = cursor.getBufferPosition()
    endScan = [0,0]
    regExp = ///
      (def|class|module|[A-Z_]+\s*=) # [1] determines what is being defined
      \s+                            # spaces between keyword and name
      (self)?                        # [2] determines whether or not it's a class_method
      \.?                            # period that exists for class_method
      (\w+)?                         # [3] class, method, or module name
      (\(.*\))?                      # [4] params
    ///
    editor.backwardsScanInBufferRange regExp, [scanStart, endScan], (element) =>
      row.params = element.match[4]
      row.number = element.range.end.row
      if element.match[1] is 'def'
        row.name = "#{if element.match[2] is 'self' then '.' else '#'}" + element.match[3]
        row.type = "#{if element.match[2] is 'self' then 'class_' else ''}method"
      else if element.match[1].match /[A-Z_]+\s*=/
        row.name = element.match[1].replace('=', '').trim()
        row.type = 'constant'
      else
        row.name = element.match[3]
        row.type = element.match[1]
      element.stop()
    row

  commentAlreadyExists: (editor, row) ->
    if row.number is 0 then return false
    if row.type is 'constant' then return editor.lineTextForBufferRow(row.number).match(/# /)

    rowAbove = editor.lineTextForBufferRow(row.number - 1)
    if row.type.match(/method/)
      rowAbove.match(/# @return/)
    else
      rowAbove.match(/# /)

  insertSnippet: (editor, cursor, definitionRowNumber, comment, printAbove) ->
    cursor.setBufferPosition([definitionRowNumber, 0])
    editor.moveToFirstCharacterOfLine()
    indentation = cursor.getIndentLevel()
    if printAbove
      editor.insertNewlineAbove()
      editor.setIndentationForBufferRow(cursor.getBufferRow(), indentation)
    else
      editor.moveToEndOfLine()
      comment = ' ' + comment
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
