Toc = require './Toc'

module.exports =

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'markdown-toc:create': =>
        @toc = new Toc(atom.workspace.getActivePaneItem())
        @toc.create()
    atom.commands.add 'atom-workspace', 'markdown-toc:update': =>
        @toc = new Toc(atom.workspace.getActivePaneItem())
        @toc.update()
    atom.commands.add 'atom-workspace', 'markdown-toc:delete': =>
        @toc = new Toc(atom.workspace.getActivePaneItem());
        @toc.delete()
    atom.commands.add 'atom-workspace', 'markdown-toc:toggle': =>
        @toc = new Toc(atom.workspace.getActivePaneItem())
        @toc.toggle()

  # deactivate: ->
  #   @toc.destroy()
