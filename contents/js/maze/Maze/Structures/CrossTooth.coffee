Maze.Structures.CrossTooth =
  directions: (i) -> [ 0, 1, 2 ]

  translateDirection: (i, direction) ->
    width = @width
    height = @height
    mazeCol = i % width
    mazeRow = Math.floor(i / width)

    orientation = mazeRow % 4
    switch orientation
      when 0 # Pointing down
        switch direction
          when 0
            if mazeRow > 0
              i - width
          when 1 then i + width * 2
          when 2 then i + width
      when 1 # Pointing right
        switch direction
          when 0
            if mazeCol > 0
              i + width - 1
          when 1 then i - width
          when 2 then i + width * 2
      when 2 # Pointing left
        switch direction
          when 0
            if mazeCol < width - 1
              i - width + 1
          when 1 then i + width
          when 2 then i - width * 2
      when 3 # Pointing up
        switch direction
          when 0
            if mazeRow < height - 1
              i + width
          when 1 then i - width * 2
          when 2 then i - width
