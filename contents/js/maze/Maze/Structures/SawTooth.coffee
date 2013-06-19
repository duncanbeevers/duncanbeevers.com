Maze.Structures.SawTooth =
  directions: (i) ->
    [ 0, 1, 2 ]

  translateDirection: (i, direction) ->
    width = @width
    height = @height

    mazeCol = i % width
    mazeRow = Math.floor(i / width)
    pointDown = (mazeRow % 2 == 0)

    switch direction
      when 0
        if pointDown
          if mazeRow > 0
            i - width
        else
          if mazeRow < height - 1
            i + width
      when 1
        if pointDown
          i + width
        else
          i - width
      when 2
        if pointDown
          if mazeCol > 0
            i + (width - 1)
        else
          if mazeCol < width - 1
            i - (width - 1)