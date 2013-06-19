class Maze.Projections.CrossTooth extends Maze.Projections.BaseProjection
  rowHeight: 4
  project: (maze, i, cache) ->
    cell = maze.cell(i)
    mazeCol = i % maze.width
    mazeRow = Math.floor( i / maze.width)

    orientation = mazeRow % 4

    x = mazeCol - maze.width / 2
    y = Math.floor(mazeRow / 4) - maze.height / 8

    switch orientation
      when 0 # Pointing down
        @segmentsForCellCircuit(i, cell, [
          [ x, y ]
          [ x + 1, y ]
          [ x + 0.5, y + 0.5 ]
        ], cache)
      when 1 # Pointing right
        @segmentsForCellCircuit(i, cell, [
          [ x, y + 1 ]
          [ x, y ]
          [ x + 0.5, y + 0.5 ]
        ], cache)
      when 2 # Pointing left
        @segmentsForCellCircuit(i, cell, [
          [ x + 1, y ]
          [ x + 1, y + 1]
          [ x + 0.5, y + 0.5 ]
        ], cache)
      when 3 # Pointing up
        @segmentsForCellCircuit(i, cell, [
          [ x + 1, y + 1]
          [ x, y + 1 ]
          [ x + 0.5, y + 0.5 ]
        ], cache)
