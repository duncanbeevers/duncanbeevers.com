Maze = @Maze ||= {}
Maze.Projections = Maze.Projections ||= {}

class Maze.Projections.BaseProjection
  rowHeight: 1
  columnWidth: 1
  segmentsForCellCircuit: (i, cell, points, cache) ->
    segments = []

    for direction, _i in cell
      [x, y] = points[_i]
      [_x, _y] = points[(_i + 1) % points.length]

      [destination, open] = cell[_i]

      if !open
        if destination == undefined
          drawWall = true
        else if cache
          key = [ i, destination ].sort().join(":")
          drawWall = !cache[key]
          cache[key] = true
        else
          drawWall = true

        if drawWall
          segments.push([ x, y, _x, _y ])

      [_x, _y] = [x, y]

    segments

  infer: (maze, x, y) ->
    bestI = undefined
    bestDistance = Infinity
    for i in [0..(maze.width * maze.height)]
      segments = @project(maze, i)
      [centerX, centerY] = FW.Math.centroidOfSegments(segments)
      distance = FW.Math.distance(x, y, centerX, centerY)
      if distance < bestDistance
        bestDistance = distance
        bestI = i
    bestI
