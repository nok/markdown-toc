module.exports =
class Toc


  constructor: (@editor) ->
    @lines = []
    @list = []
    @options =
      depthFrom: 1  # depthFrom
      depthTo: 6  # depthTo
      withLinks: 1  # withLinks
      updateOnSave: 1 # updateOnSave
      orderedList: 0 # orderedList
    @create()

    at = @
    @editor.getBuffer().onWillSave () ->
      if at.options.updateOnSave is 1
        if at._hasToc()
          at._deleteToc()
          at.editor.setTextInBufferRange [[at.open,0], [at.open,0]], at._createToc()


  # ----------------------------------------------------------------------------
  # main methods (highest logic level)


  create: ->
    if @_hasToc()
      @_deleteToc()
      @editor.setTextInBufferRange [[@open,0], [@open,0]], @_createToc()
    @editor.insertText @_createToc()


  update: ->
    if @_hasToc()
      @_deleteToc()
      @editor.setTextInBufferRange [[@open,0], [@open,0]], @_createToc()
    else
      @editor.insertText @_createToc()


  delete: ->
    if @_hasToc()
      @_deleteToc()


  autosave: ->
    if @_hasToc()
      @_deleteToc()
      @editor.setTextInBufferRange [[@open,0], [@open,0]], @_createToc()



  # ----------------------------------------------------------------------------


  _hasToc: () ->
    @___updateLines()

    if @lines.length > 0
      @open = false
      @close = false
      options = undefined

      for i of @lines
        line = @lines[i]
        if @open is false
          if line.match /^<!--(.*)TOC(.*)-->$/g
            @open = parseInt i
            options = line
        else
          if line.match /^<!--(.*)\/TOC(.*)-->$/g
            @close = parseInt i
            break

      if @open isnt false and @close isnt false
        if options isnt undefined
          @__updateOptions options
          return true
    return false


  # embed list with the open and close comment:
  # <!-- TOC --> [list] <!-- /TOC -->
  _createToc: () ->
    @__updateList()
    if Object.keys(@list).length > 0
      text = []
      text.push "<!-- TOC depthFrom:"+@options.depthFrom+" depthTo:"+@options.depthTo+" withLinks:"+@options.withLinks+" updateOnSave:"+@options.updateOnSave+" orderedList:"+@options.orderedList+" -->\n"
      list = @__createList()
      if list isnt false
        Array.prototype.push.apply text, list
      text.push "\n<!-- /TOC -->"
      return text.join "\n"
    return ""


  _deleteToc: () ->
    @editor.setTextInBufferRange [[@open,0], [@close,14]], ""


  # ----------------------------------------------------------------------------


  # parse all lines and find markdown headlines
  __updateList: () ->
    @___updateLines()
    @list = []
    for i of @lines
      line = @lines[i]
      result = line.match /^\#{1,6}/
      if result
        depthFrom = if @options.depthFrom isnt undefined then @options.depthFrom else 1
        depthTo = if @options.depthTo isnt undefined then @options.depthTo else 6
        if (result[0].length <= parseInt depthTo) and (result[0].length >= parseInt depthFrom)
          @list.push
            depth: result[0].length
            line: new String line


  # create hierarchical markdown list
  __createList: () ->
    list = []
    depthFrom = if @options.depthFrom isnt undefined then @options.depthFrom else 1
    depthTo = if @options.depthTo isnt undefined then @options.depthTo else 6
    indicesOfDepth = Array.apply(null, new Array(depthTo - depthFrom)).map(Number.prototype.valueOf, 0);
    for own i, item of @list
      row = []
      for tab in [depthFrom..item.depth] when tab > depthFrom
        row.push "\t"
      if @options.orderedList is 1
        row.push ++indicesOfDepth[item.depth-1] + ". "
        indicesOfDepth = indicesOfDepth.map((value, index) -> if index < item.depth then value else 0)
      else
        row.push "- "

      line = item.line.substr item.depth
      line = line.trim()
      if @options.withLinks is 1
        row.push @___createLink line
      else
        row.push line

      list.push row.join ""
    if list.length > 0
      return list
    return false


  __updateOptions: (line) ->
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

        if key.toLowerCase().valueOf() is new String("depthfrom").valueOf()
          @options.depthFrom = parseInt value
        else if key.toLowerCase().valueOf() is new String("depthto").valueOf()
          @options.depthTo = parseInt value
        else if key.toLowerCase().valueOf() is new String("withlinks").valueOf()
          @options.withLinks = parseInt value
        else if key.toLowerCase().valueOf() is new String("updateonsave").valueOf()
          @options.updateOnSave = parseInt value
        else if key.toLowerCase().valueOf() is new String("orderedlist").valueOf()
          @options.orderedList = parseInt value


  # ----------------------------------------------------------------------------
  # lightweight methods


  # update raw lines after initialization or changes
  ___updateLines: ->
    if @editor isnt undefined
      @lines = @editor.getBuffer().getLines()
    else
      @lines = []


  # create hash and surround link withit
  ___createLink: (name) ->
    hash = new String name
    hash = hash.toLowerCase().replace /\s/g, "-"
    hash = hash.replace /[^a-z0-9\-]/g, ""
    if hash.indexOf("--") > -1
      hash = hash.replace /(-)+/g, "-"
    if name.indexOf(":-") > -1
      hash = hash.replace /:-/g, "-"
    link = []
    link.push "["
    link.push name
    link.push "](#"
    link.push hash
    link.push ")"
    return link.join ""
