Maze.Structures.Honeycomb =
  directions: (i) -> [ 0, 1, 2, 3, 4 ,5 ]
  translateDirection: (i, direction) ->
    width = @width
    height = @height
    mazeCol = i % width
    mazeRow = Math.floor(i / width)

    staggered = mazeRow % 2

    switch staggered
      when 0
        switch direction
          when 0 # NW
            if mazeCol > 0 && mazeRow > 0
              i - width - 1
          when 1 # NE
            if mazeRow > 0
              i - width
          when 2 # E
            if mazeCol < width - 1
              i + 1
          when 3 # SE
            if mazeRow < height - 1
              i + width
          when 4 # SW
            if mazeRow < height - 1 && mazeCol > 0
              i + width - 1
          when 5 # W
            if mazeCol > 0
              i - 1
      when 1
        switch direction
          when 0 # NW
            i - width
          when 1 # NE
            if mazeCol < width - 1
              i - width + 1
          when 2 # E
            if mazeCol < width - 1
              i + 1
          when 3 # SE
            if mazeRow < height - 1 && mazeCol < width - 1
              i + width + 1
          when 4 # SW
            if mazeRow < height - 1
              i + width
          when 5 # W
            if mazeCol > 0
              i - 1
