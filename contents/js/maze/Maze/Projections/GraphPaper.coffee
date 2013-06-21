BaseProjection = require("./BaseProjection.coffee").BaseProjection

class @GraphPaper extends BaseProjection
  project: (maze, i, cache) ->
    cell = maze.cell(i)
    width = maze.width
    height = maze.height
    halfWidth = width / 2
    halfHeight = height / 2

    x = i % width - halfWidth
    y = Math.floor(i / width) - halfHeight

    @segmentsForCellCircuit(i, cell, [
      [ x, y ]
      [ x + 1, y ]
      [ x + 1, y + 1 ]
      [ x, y + 1 ]
    ], cache)
