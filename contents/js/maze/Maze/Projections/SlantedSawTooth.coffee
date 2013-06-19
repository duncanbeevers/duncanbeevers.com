class Maze.Projections.SlantedSawTooth extends Maze.Projections.BaseProjection
  constructor: (options) ->
    options ||= {}
    @peakAngle = FW.Math.clamp(options.peakAngle || 60, 15, 175)
    halfBaseWidth = Math.sin(@peakAngle / 2 * FW.Math.DEG_TO_RAD)
    @_baseWidth = halfBaseWidth * 2
    @_rowHeight = 1 - halfBaseWidth

  project: (maze, i, cache) ->
    baseWidth = @_baseWidth
    rowHeight = @_rowHeight
    cell = maze.cell(i)
    mazeCol = i % maze.width
    mazeRow = Math.floor(i / maze.width)
    mazeWidth = (Math.floor(maze.height / 2) + maze.width) * baseWidth
    mazeHeight = maze.height * rowHeight / 2

    pointUp = mazeRow % 2

    x = (mazeCol * baseWidth) +
        Math.floor((mazeRow + 1) / 2) * (baseWidth / 2) -
        mazeWidth / 2

    y = Math.floor(mazeRow / 2) * rowHeight - mazeHeight / 2

    if pointUp
      @segmentsForCellCircuit(i, cell, [
        [ x + baseWidth, y + rowHeight ]
        [ x, y + rowHeight ]
        [ x + baseWidth / 2, y ]
      ], cache)
    else
      @segmentsForCellCircuit(i, cell, [
        [ x, y ]
        [ x + baseWidth, y ]
        [ x + baseWidth / 2, y + rowHeight ]
      ], cache)
