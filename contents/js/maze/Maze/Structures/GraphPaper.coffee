Maze = @Maze ||= {}
Maze.Structures ||= {}

Maze.Structures.GraphPaper =
  directions: (i) ->
    [
      0 # NORTH
      1 # EAST
      2 # SOUTH
      3 # WEST
    ]

  # Perimeter is enforced as invalid translation result
  translateDirection: (i, direction) ->
    width = @width
    height = @height
    x = i % width
    y = Math.floor(i / width)

    switch direction
      when 0 # NORTH
        if y > 0
          i - width
      when 1 # EAST
        if x < width - 1
          i + 1
      when 2 # SOUTH
        if y < height - 1
          i + width
      when 3 # WEST
        if x > 0
          i - 1
