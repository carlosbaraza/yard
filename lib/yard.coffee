{CompositeDisposable} = require 'atom'
Snippets = require atom.packages.resolvePackagePath('snippets') + '/lib/snippets.js'

module.exports = Yard =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "yard:create", => @create()

  config:
    ensureBlankLineBeforeDescription:
      type: 'boolean'
      default: true
    addCommentLineBeforeDescription:
      type: 'boolean'
      default: false
    addCommentLineAfterClassOrModuleDescription:
      type: 'boolean'
      default: false
    addCommentLineAfterMethodDescription:
      type: 'boolean'
      default: true
    addCommentLineBeforeParams:
      type: 'boolean'
      default: false
    addCommentLineAfterParams:
      type: 'boolean'
      default: false
    addCommentLineBeforeReturn:
      type: 'boolean'
      default: false
    addCommentLineAfterReturn:
      type: 'boolean'
      default: false

  create: ->
    editor = atom.workspace.getActivePaneItem()
    cursor = editor.getLastCursor()
    editor.transact =>
      row = @parseStartRow(editor, cursor)
      if !row.type or @commentAlreadyExists(editor, row) then return
      comment = @buildComment(editor, row)
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
      else if /[A-Z_]+\s*=/.test element.match[1]
        row.name = element.match[1].replace('=', '').trim()
        row.type = 'constant'
      else
        row.name = element.match[3]
        row.type = element.match[1]
      element.stop()
    row

  commentAlreadyExists: (editor, row) ->
    if row.number is 0 then return false
    currentRow = editor.lineTextForBufferRow(row.number)
    rowAbove = editor.lineTextForBufferRow(row.number - 1)
    switch
      when /constant/.test row.type
        /# /.test currentRow
      when /method/.test row.type
        /# @return/.test rowAbove
      else
        /# /.test rowAbove

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

  buildComment: (editor, row) ->
    comment = ''
    index = 0
    if row.type isnt 'constant'
      if row.number isnt 0 and editor.lineTextForBufferRow(row.number - 1).trim().length isnt 0
        if atom.config.get('yard.ensureBlankLineBeforeDescription') then comment += "\n"
    if atom.config.get('yard.addCommentLineBeforeDescription') then comment += "\n#"
    # Description
    comment += "# ${#{index+=1}:Description of #{row.name}}"
    switch
      when /method/.test row.type
        if atom.config.get('yard.addCommentLineAfterMethodDescription') then comment += "\n#"
        params = @buildParams(row.params)
        for param in params
          if atom.config.get('yard.addCommentLineBeforeParams') then comment += "\n#"
          # @param
          comment += "\n# @param [${#{index+=1}:Type}] #{param.argument} "
          description = if param.default then "default: #{param.default}" else "describe_#{param.argument}_here"
          comment += "${#{index+=1}:#{description}}"
          if atom.config.get('yard.addCommentLineAfterParams') then comment += "\n#"
        if atom.config.get('yard.addCommentLineBeforeReturn') then comment += "\n#"
        # @return
        comment += "\n# @return [${#{index+=1}:Type}] ${#{index+1}:description_of_returned_object}"
        if atom.config.get('yard.addCommentLineAfterReturn') then comment += "\n#"

      when /\A(class|module)\z/.test row.type
        if atom.config.get('yard.addCommentLineAfterClassOrModuleDescription') then comment += "\n#"

    comment

  buildParams: (paramString) =>
    if !paramString then return []
    paramsArray = paramString.replace(/\(|\)/g, '').split(',')
    for param in paramsArray
      paramMatch = param.match /(\w+)\s*([=:])?\s*(.+)?/
      { argument: paramMatch[1], default: paramMatch[2] && (paramMatch[3] || 'nil') }
