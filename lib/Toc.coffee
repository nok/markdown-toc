module.exports =
class Toc

  constructor: (@pane) ->
    @lines = []
    @list = {}
    @options = {} # depth/links/update

    @updateLines()

    if @hasToc()
      @updateToc()
      # cursorRow = @pane.getCursor().getScreenRow()
    else
      @pane.insertText @createToc()

    # changes
    at = @
    @pane.onDidChange (change) ->
      at.onChange(change)


  updateLines: ->
    if @pane isnt undefined
      @lines = @pane.getBuffer().getLines()
    else
      @lines = []


  updateList: () ->
    @list = {}
    for i of @lines
      line = @lines[i]
      result = line.match /^\#{1,6}/
      if result
        depth = if @options.depth isnt undefined then @options.depth else 6
        if result[0].length <= parseInt depth
          @list[result[0].length] = line


  createToc: () ->
    @updateList()
    if Object.keys(@list).length > 0
      text = []
      text.push "<!-- TOC depth:6 links:1 update:1 -->"
      list = @createList()
      if list isnt false
        Array.prototype.push.apply text, list
      text.push "<!-- /TOC -->"
      return text.join "\n"
    return ""


  updateToc: () ->
    # TODO implement update
    console.log 'update toc'


  createList: () ->
    list = []
    for own level, line of @list
      row = []
      for tab in [1..level] when tab > 1
        row.push "\t"
      row.push "- "
      line = line.substr level
      line = line.trim()
      row.push line
      list.push row.join ""
    if list.length > 0
      return list
    return false


  updateOptions: (line) ->
    options = line.match /(\w+(=|:)(\d|yes|no))+/g
    if options
      @options = {}
      for i of options
        option = options[i]

        key = option.match /^(\w+)/g
        key = new String key[0]

        value = option.match /(\d|yes|no)$/g
        value = new String value[0]
        if value.length > 1
          if value.toLowerCase().valueOf() is new String("yes").valueOf()
            value = 1
          else
            value = 0

        if key.toLowerCase().valueOf() is new String("depth").valueOf()
          @options.depth = parseInt value
        else if key.toLowerCase().valueOf() is new String("links").valueOf()
          @options.links = parseInt value


  hasToc: () ->
    if @lines.length > 0
      open = undefined
      close = undefined
      options = undefined

      for i of @lines
        line = @lines[i]
        if open is false
          if line.match /^<!--(.*)TOC(.*)-->$/g
            open = i
            options = line
        else
          if line.match /^<!--(.*)\/TOC(.*)-->$/g
            close = i
            break

      if open isnt undefined and close isnt undefined
        if options isnt undefined
          @updateOptions options
          return true

    return false


  onChange: (change) ->
    @updateLines()
    @updateToc()
