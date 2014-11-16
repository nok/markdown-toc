module.exports =
class Toc

  tree:
    open:
      pattern: /<!-- TOC -->/g
      line: undefined
    close:
      pattern: /<!-- \/TOC -->/g
      line: undefined
    has: false
    data: {}

  # lines
  # table

  constructor: (@pane) ->
    @updateLines()

    @table = new Array

    # cursorRow = @pane.getCursor().getScreenRow()

    if @hasToc @lines
      # update toc
      console.log 'update'
    else
      # create toc
      @pane.insertText @createToc()

    at = @
    @pane.onDidChange (change) ->
      at.onChange(change)

  updateLines: ->
    if @pane isnt undefined
      @lines = @pane.getBuffer().getLines()
    else
      @lines = new Array

  updateTable: (level=6) ->
    @table = {}

    for i of @lines
      line = @lines[i]
      result = line.match /^\#{1,6}/
      if result
        if result[0].length <= level
          @table[result[0].length] = line

  createToc: () ->
    @updateTable()

    if Object.keys(@table).length > 0
      text = new Array
      text.push "<!-- TOC -->"
      for own level, line of @table
        row = new Array
        for tab in [1..level] when tab > 1
          row.push "\t"
        row.push "- "
        line = line.substr level
        line = line.trim()
        row.push line
        text.push row.join ""
      text.push "<!-- /TOC -->"
      return text.join "\n"
    return ""

  hasToc: (lines) ->
    if lines.length > 0

      openToc = undefined
      closeTo = undefined

      for i of lines
        line = lines[i]

        if openToc is undefined
          if line.match @tree.open.pattern
            openToc = i
        else
          if line.match @tree.close.pattern
            closeToc = i
            break

      @tree.has = openToc isnt undefined and closeToc isnt undefined
      return @tree.has
    return false

  onChange: (change) ->
    @updateLines()
    console.log change

    # if @hasToc @getLines()
    #   console.log 'has TOC'
    #   console.log '-> update'
    # else
    #   console.log 'hasnt TOC'
    #   console.log '-> insert?'
