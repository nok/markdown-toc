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

  constructor: (pane) ->
    @pane = pane

    if !@hasToc @getLines()
      cursorRow = @pane.getCursor().getScreenRow()

      text = new Array();
      text.push("<!-- TOC -->");
      text.push("- a");
      text.push("- b");
      text.push("<!-- /TOC -->");
      text = text.join("\n");

      @pane.insertText(text)


    at = @
    @pane.onDidChange (change) ->
      at.onChange(change)

  getLines: ->
    return @pane.getBuffer().getLines()

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
    if @hasToc @getLines()
      console.log 'has TOC'
      console.log '-> update'
    else
      console.log 'hasnt TOC'
      console.log '-> insert?'
