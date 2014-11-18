Toc = require './Toc'

module.exports =

  activate: (state) ->
    @toc = new Toc(atom.workspace.getActivePaneItem())

    atom.commands.add 'atom-workspace', 'markdown-toc:create': => @toc.create()
    atom.commands.add 'atom-workspace', 'markdown-toc:update': => @toc.update()
    atom.commands.add 'atom-workspace', 'markdown-toc:delete': => @toc.delete()

  # deactivate: ->
  #   @toc.destroy()
