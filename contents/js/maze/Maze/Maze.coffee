generateMaze = (maze, done) ->
  recurse(maze, maze.initialIndex(), false)

recurse = (maze, i, didBacktrack) ->
  cache = maze._projectionEdgeCache
  passages = maze._passages

  # Track whether we are back at the beginning
  # (ie, stack is empty and no direction to turn)
  bottomedOut = false
  if !didBacktrack
    markTraversed(maze, i)

  # From where we are, pick at random, a valid direction to travel in
  direction = pickDirection(maze, i)

  # If a valid direction was found, continue on our merry way
  if direction != undefined
    didBacktrack = false
    # Remember where we were, cause we're outta here
    maze.stack ||= []
    maze.stack.push(i)

    newI = translateDirection(maze, i, direction)

    maze._passages.push(i)
    addTunnel(maze, i, newI)
  else
    projectAndDrawMazeCell(maze, i, cache)
    # Oh no! Nowhere to turn!
    # Backtrack until we find a spot to branch off again
    if maze.stack && maze.stack.length
      if !didBacktrack
        didBacktrack = true
        maze.terminations ||= []
        pathLength = maze.stack.length
        indexLengthPair = [ i, pathLength ]
        maze.terminations.push indexLengthPair

        if !maze.maxTermination || maze.maxTermination[1] < pathLength
          maze.maxTermination = indexLengthPair

      newI = maze.stack.pop()
    else
      # Nowhere to go! At all! I guess this is it.
      bottomedOut = true

  if bottomedOut
    # Well, let's tell everyone about it
    maze.done(maze)
  else
    # We must continue on, so we hand the keys off to the
    # step call, confident our work will be continued, somehow...
    maze.step ->
      recurse(maze, newI, didBacktrack)

addTunnel = (maze, i1, i2) ->
  maze.tunnels ||= {}
  key = normalizeTunnelName(i1, i2)
  maze.tunnels[key] = true

hasTunnel = (maze, i1, i2) ->
  tunnels = maze.tunnels
  if tunnels
    tunnels[normalizeTunnelName(i1, i2)]

normalizeTunnelName = (i1, i2) ->
  [ i1, i2 ].sort().join(":")

markTraversed = (maze, i) ->
  traversed = maze.traversed ||= {}
  traversed[i] = true

translateDirection = (maze, i, direction) ->
  maze.translateDirection(i, direction)

hasBeenTraversed = (maze, i) ->
  traversed = maze.traversed
  traversed && traversed[i]

validDirection = (maze, currentIndex, direction) ->
  i = translateDirection(maze, currentIndex, direction)

  return false if i == undefined
  return false if maze.avoid(maze, i)
  return false if hasBeenTraversed(maze, i)
  true

validTranslateDirections = (maze, currentIndex) ->
  for direction in maze.directions(currentIndex) when validDirection(maze, currentIndex, direction)
    direction

pickDirection = (maze, currentIndex) ->
  directions = validTranslateDirections(maze, currentIndex)
  # Pick one at random
  return directions[Math.floor(Math.random() * directions.length)]

projectAndDrawMazeCell = (maze, i, cache) ->
  if maze.projection
    projectedSegments = maze.projectedSegments || []
    cellSegments = maze.projection.project(maze, i, cache)
    if maze.draw
      maze.draw(cellSegments)

    maze.projectedSegments = projectedSegments.concat(cellSegments)

class @Maze
  constructor: (options) ->
    @_projectionEdgeCache = {}
    @_passages = []

    defaultOptions =
      unicursal: false
      width: 4
      height: 4
      initialIndex: -> 0
      done: ->
      avoid: ->
      step: (fn) ->
        setTimeout fn, 10
        # try
        #   fn()
        # catch error
        #   if error instanceof RangeError
        #     setTimeout fn

    $.extend(@, defaultOptions, options)

    if @initialize
      @initialize()

    undefined

  cell: (i) ->
    for direction in @directions(i)
      destination = translateDirection(@, i, direction)
      tunnel = hasTunnel(@, i, destination)

      [ destination, tunnel ]

  serialize: ->
    snap = (x) -> FW.Math.snap(x, 1000)

    centroid = (segments) ->
      [x, y] = FW.Math.centroidOfSegments(segments)
      [ snap(x), snap(y) ]

    # Find the end of the maze, the furthest from the start point
    # Split out the final termination from the others
    # TODO: Substitute configurable distance calculation
    # TODO: Replace this nonMaximalTerminations with some kind of filter function
    nonMaximalTerminations = (i for [i, length] in @terminations when @maxTermination[0] != i)
    projection = @projection

    terminations = for i in nonMaximalTerminations
      centroid(projection.project(@, i))

    start = centroid(projection.project(@, @initialIndex()))
    end = centroid(projection.project(@, @maxTermination[0]))

    segments = for [x1, y1, x2, y2] in @joinedSegments || @projectedSegments
      [ snap(x1), snap(y1), snap(x2), snap(y2) ]

    passages = []
    for i in @_passages
      passage = centroid(projection.project(@, i))
      [x, y] = passage
      if (x || x == 0) && (y || y == 0)
        passages.push(passage)

    serialized =
      name: @name
      start: start
      end: end
      terminations: terminations
      segments: segments
      passages: passages

Maze = @Maze ||= {}

Maze.createInteractive = (options) ->
  extendedOptions = $.extend({}, options)
  maze = new Maze(extendedOptions)
  generateMaze(maze)
  maze

Maze.createInstantaneous = (options) ->
  extendedOptions = $.extend({}, options, step: (fn) -> fn())
  maze = new Maze(extendedOptions)
  generateMaze(maze)
  maze
