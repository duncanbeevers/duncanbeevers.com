Maze.Structures.FoldedHexagon = $.extend {}, Maze.Structures.GraphPaper,
  translateDirection: (i, direction) ->
    width = @width
    height = @height
    x = i % width
    y = Math.floor(i / width)
    halfWidth = width / 2
    halfHeight = height / 2
    startingNorthWarpIndex = halfHeight * width
    endingNorthWarpIndex = startingNorthWarpIndex + halfWidth - 1

    mirror = false
    switch direction
      when 0
        if (y == halfHeight && i >= startingNorthWarpIndex && i <= endingNorthWarpIndex)
          mirror = true
      when 3
        if x == halfWidth && y < halfHeight
          mirror = true

    if mirror
      x * width + y
    else
      # Rely on the GraphPaper template translation
      return Maze.Structures.GraphPaper.translateDirection.call(@, i, direction)

  initialIndex: () ->
    (@height - 1) * @width + 1
