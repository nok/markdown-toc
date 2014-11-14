Toc = require './Toc'

module.exports =

  activate: (state) ->
    @toc = new Toc(atom.workspace.getActivePaneItem())
