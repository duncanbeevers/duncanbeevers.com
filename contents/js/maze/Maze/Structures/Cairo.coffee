Maze = @Maze ||= {}
Maze.Structures ||= {}

Maze.Structures.Cairo =
  directions: (i) -> [ 0, 1, 2, 3, 4 ]

  translateDirection: (i, direction) ->
    width = @width
    height = @height
    mazeCol = i % width
    mazeRow = Math.floor(i / width)

    orientation = mazeRow % 4
    staggered = Math.floor(mazeRow / 4) % 2

    switch orientation
      when 0 # Pointing up
        switch direction
          when 0 # NW
            if mazeRow > 0
              if staggered
                i - 2 * width
              else
                if mazeCol > 0
                  i - 2 * width - 1
          when 1 # NE
            if mazeRow > 0
              if staggered
                if mazeCol < width - 1
                  i - 3 * width + 1
              else
                i - 3 * width
          when 2 # SE
            if staggered
              i + 2 * width
            else
              i + 2 * width
          when 3 # S
            if staggered
              i + 3 * width
            else
              i + 3 * width
          when 4 # SW
            if staggered
              i + width
            else
              i + width
      when 1 # Pointing right
        switch direction
          when 0 # NE
            if staggered
              i - width
            else
              i - width
          when 1 # SE
            if staggered
              i + 2 * width
            else
              i + 2 * width
          when 2 # SW
            if staggered
              if mazeRow < height - 3
                i + 3 * width
            else
              if mazeCol > 0 && mazeRow < height - 3
                i + 3 * width - 1
          when 3 # W
            if staggered
              if mazeCol > 0
                i + width - 1
            else
              if mazeCol > 0
                i + width - 1
          when 4 # NW
            if staggered
              i - 2 * width
            else
              if mazeCol > 0 && mazeRow > 1
                i - 2 * width - 1
      when 2 # Pointing left
        switch direction
          when 0 # SW
            if staggered
              i + width
            else
              i + width
          when 1 # NW
            if staggered
              i - 2 * width
            else
              i - 2 * width
          when 2 # NE
            if staggered
              if mazeCol < width - 1
                i - 3 * width + 1
            else
              if mazeRow > 2
                i - 3 * width
          when 3 # E
            if staggered
              if mazeCol < width - 1
                i - width + 1
            else
              if mazeCol < width - 1
                i - width + 1
          when 4 # SE
            if staggered
              if mazeCol < width - 1 && mazeRow < height - 2
                i + 2 * width + 1
            else
              if mazeRow < height - 2
                i + 2 * width
      when 3 # Pointing down
        switch direction
          when 0 # SE
            if staggered
              if mazeCol < width - 1 && mazeRow < height - 1
                i + 2 * width + 1
            else
              if mazeRow < height - 1
                i + 2 * width
          when 1 # SW
            if staggered
              if mazeRow < height - 1
                i + 3 * width
            else
              if mazeCol > 0 && mazeRow < height - 1
                i + 3 * width - 1
          when 2 # NW
            if staggered
              i - 2 * width
            else
              i - 2 * width
          when 3 # N
            if staggered
              i - 3 * width
            else
              i - 3 * width
          when 4 # NE
            if staggered
              i - width
            else
              i - width