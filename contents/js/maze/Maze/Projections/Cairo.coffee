class Maze.Projections.Cairo extends Maze.Projections.BaseProjection
  rowHeight: 4
  project: (maze, i, cache) ->
    cell = maze.cell(i)
    mazeCol = i % maze.width
    mazeRow = Math.floor(i / maze.width)

    orientation = mazeRow % 4
    staggered = Math.floor(mazeRow / 4) % 2

    alpha = 0.8660254037844387 # Math.cos(FW.Math.DEG_TO_RAD * 30)
    beta = 0.5 # Math.cos(FW.Math.DEG_TO_RAD * 60)

    xOffset = 0
    if staggered
      xOffset = 2 * alpha

    x = (mazeCol - maze.width / 2 + 0.25) * 4 * alpha + xOffset
    y = (Math.floor(mazeRow / 4) - (maze.height / 8) + 0.5) * (2 * alpha + 0.07)

    switch orientation
      when 0 # Pointing up
        @segmentsForCellCircuit(i, cell, [
          [ x - alpha, y - alpha ]
          [ x, y - alpha - beta ]
          [ x + alpha, y - alpha ]
          [ x + alpha - beta, y ]
          [ x + beta - alpha, y ]
        ], cache)

      when 1 # Pointing right
        @segmentsForCellCircuit(i, cell, [
          [ x - alpha, y - alpha ]
          [ x + beta - alpha, y ]
          [ x - alpha, y + alpha ]
          [ x - 2 * alpha, y + beta ]
          [ x - 2 * alpha, y - beta ]
        ], cache)

      when 2 # Pointing left
        @segmentsForCellCircuit(i, cell, [
          [ x + alpha, y + alpha ]
          [ x + alpha - beta, y ]
          [ x + alpha, y - alpha ]
          [ x + 2 * alpha, y - beta ]
          [ x + 2 * alpha, y + beta ]
        ], cache)

      when 3 # Pointing down
        @segmentsForCellCircuit(i, cell, [
          [ x + alpha, y + alpha ]
          [ x, y + alpha + beta ]
          [ x - alpha, y + alpha ]
          [ x + beta - alpha, y ]
          [ x + alpha - beta, y ]
        ], cache)
