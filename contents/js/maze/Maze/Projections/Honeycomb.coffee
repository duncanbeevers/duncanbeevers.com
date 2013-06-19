class Maze.Projections.Honeycomb extends Maze.Projections.BaseProjection
  project: (maze, i, cache) ->
    w = 0.577350269189626   # 1 / Math.tan(FW.Math.DEG_TO_RAD * 60)
    h = 1.1547005383792517  # Math.sqrt(1 + Math.pow(w, 2))

    hexWidth = 2
    hexHeight = w + h

    cell = maze.cell(i)
    mazeX = i % maze.width
    mazeY = Math.floor(i / maze.width)

    staggered = mazeY % 2

    xOffset = 0
    if staggered
      xOffset = 1

    x = (mazeX - maze.width / 2 - 0.25) * hexWidth + xOffset
    y = (mazeY - maze.height / 2) * hexHeight

    @segmentsForCellCircuit(i, cell, [
      [ x, y + w ]
      [ x + 1, y ]
      [ x + 2, y + w]
      [ x + 2, y + w + h ]
      [ x + 1, y + w + w + h ]
      [ x, y + w + h ]
    ], cache)
