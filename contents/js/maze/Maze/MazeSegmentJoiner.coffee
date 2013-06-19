SortedSet = require("../FW/SortedSet").FW.SortedSet

Maze = @Maze ||= {}

coordPairComparison = (a, b) ->
  [x1, y1] = a
  [x2, y2] = b

  if x1 < x2
    # First sort by x
    return -1
  else if x1 == x2
    # In case of tie, sort by y
    if y1 < y2
      return -1
    else if y1 == y2
      # Explode here? These points are the same
      # and should just be collapsed.
    else
      return 1
  else
    return 1

# Normalize pairs, x1 is always <= x2, when x1 == x2, y1 <= y2
normalizeCoordPairs = (coordPairs, draw, next) ->
  normalize = (coordPairs, i, draw, next) ->
    coordPair = coordPairs[i]
    normalized = false
    if coordPair[2] < coordPair[0] || (coordPair[2] == coordPair[0] && coordPair[3] < coordPair[1])
      normalized = true
      coordPair.unshift(coordPair.pop())
      coordPair.unshift(coordPair.pop())

    data =
      type: 'normalizedSegment'
      normalized: normalized
      segment: coordPair

    draw data, ->
      if i < coordPairs.length - 1
        normalize(coordPairs, i + 1, draw, next)
      else
        next(coordPairs)

  normalize(coordPairs, 0, draw, next)


distance = (x, y) ->
  Math.sqrt(Math.abs(Math.pow(x, 2) + Math.pow(y, 2)))

joinSegments = (map, draw, next) ->
  threshold = 0.05
  # Now that the data is partitioned by slope/intercept, sort the groups
  # of segments within each group
  scalar = 1000
  collectedSegments = []

  keys = (key for key, segments of map)

  processSlopeIntercept = (map, keys, i, draw, next) ->
    segments = map[keys[i]]
    segments.sort coordPairComparison

    # We're sorted, so lets start joining up segments
    processSegment = (segments, k, draw, next) ->
      currSegment = segments[k]
      [ x3, y3, x4, y4 ] = currSegment

      joined = false
      skipped = false
      if k == 0
        collectedSegments.push currSegment
      else
        # Cache prevSegment?
        prevSegment = collectedSegments[collectedSegments.length - 1]

        [ x1, y1, x2, y2 ] = prevSegment

        len = distance(x3 - x2, y3 - y2)

        if len < threshold
          # Joinable
          joined = true
          prevSegment[2] = currSegment[2]
          prevSegment[3] = currSegment[3]
        else
          skipped = true
          # Gap
          collectedSegments.push currSegment

      if joined
        dataSegment = prevSegment
      else
        dataSegment = currSegment

      data =
        type: "joinAttempt"
        segment: dataSegment
        joined: joined
        skipped: skipped

      draw data, ->
        if k < segments.length - 1
          processSegment(segments, k + 1, draw, next)
        else
          next()

    processSegment segments, 0, draw, ->
      data =
        type: 'processSegment'

      draw data, ->
        if i < keys.length - 1
          processSlopeIntercept(map, keys, i + 1, draw, next)
        else
          next(collectedSegments)

  processSlopeIntercept(map, keys, 0, draw, next)

slopeInterceptMap = (normalizedSegments, draw, next) ->
  # Partition the segments into a 2 dimentionsal data structure
  # First cluster all segments with similar slope
  # Then within those clusters, cluster by y-intercept
  scalar = 1000
  uniqueIntercepts = new SortedSet(SortedSet.FuzzyNumericalComparator(0.1))

  map = {}
  process = (normalizedSegments, i, draw, next) ->
    coordPair = normalizedSegments[i]
    [x1, y1, x2, y2] = coordPair

    minDistance = 0.05
    len = distance(x2 - x1, y2 - y1)

    if len > minDistance
      slope = (y2 - y1) / (x2 - x1)

      if isFinite slope
        intercept = -slope * x1 + y1
      else
        slope = Math.abs(slope)
        intercept = x2

      intercept = uniqueIntercepts.insert(intercept)

      slopeKey = Math.floor(slope * scalar)
      interceptKey = Math.floor(intercept * scalar)

      key = "#{slopeKey}:#{interceptKey}"

      segments = map[key] ||= []
      segments.push(coordPair)

    data =
      type: "slopeInterceptMap"
      slope: slope
      intercept: intercept
      slopeKey: slopeKey
      interceptKey: interceptKey
      intercepts: uniqueIntercepts.collection()
      segment: coordPair

    draw data, ->
      if i < normalizedSegments.length - 1
        process(normalizedSegments, i + 1, draw, next)
      else
        next(map)

  process(normalizedSegments, 0, draw, next)

class Maze.SegmentJoiner
  constructor: (coordPairs, draw) ->
    @_coordPairs = coordPairs
    @_draw = draw

  solve: (onSolved) ->
    joiner = @
    coordPairs = @_coordPairs
    draw       = @_draw || (data, next) -> setTimeout next

    normalize = (coordPairs, next) -> normalizeCoordPairs(coordPairs, draw, next)
    map       = (normalized, next) -> slopeInterceptMap(normalized, draw, next)
    join      =        (map, next) -> joinSegments(map, draw, next)

    normalize @_coordPairs, (normalized) ->
      map normalized, (map) ->
        # Store map reference for inspection
        # Maybe tear this out
        joiner.slopeInterceptMap = map
        join map, (solution) ->
          # Store the joinedSegments for inspection
          # Used for translation to physics bodies
          # Maybe tear this out?
          joiner.joinedSegments = solution
          onSolved(solution)
