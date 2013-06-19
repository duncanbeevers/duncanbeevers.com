class Maze.Projections.SawTooth extends Maze.Projections.BaseProjection
  rowHeight: 2
  project: (maze, i, cache) ->
    cell = maze.cell(i)
    mazeCol = i % maze.width
    mazeRow = Math.floor(i / maze.width)

    pointUp = mazeRow % 2

    x = mazeCol - maze.width / 2
    y = Math.floor(mazeRow / 2) - maze.height / 4

    if pointUp
      @segmentsForCellCircuit(i, cell, [
        [ x + 1, y + 1 ]
        [ x, y + 1 ]
        [ x + 1, y ]
      ], cache)
    else
      @segmentsForCellCircuit(i, cell, [
        [ x, y ]
        [ x + 1, y ]
        [ x, y + 1 ]
      ], cache)
