PI = Math.PI
TWO_PI = PI * 2

# Returns random numbers
# Given no arguments, it returns a random number between 0 and 1
# Given one argument, it returns a random number between 0 and the provided number
# Given two arguments, it returns a random number between the two provided numbers
random = (args...) ->
  switch args.length
    when 0
      range = 1
      min = 0
    when 1
      range = args[0]
      min = 0
    when 2
      range = args[1] - args[0]
      min = args[0]

  return (Math.random() * range) + min

rand = (args...) ->
  Math.floor(random.apply(@, args))

# Locks a value within a range.
# If the value is less than min, returns min
# If the value is greater than max, returns max
# If the value is between min and max, returns value
clamp = (value, min, max) ->
  return Math.min(Math.max(min, value), max)

# Normalizes the provided value to a 0 to 2pi radian range
# This means original orientation is preserved
wrapToCircle = (value) ->
  wrapToCap(value, TWO_PI)

wrapToHalfCircle = (value) ->
  wrapToCap(value, PI)

wrapToCircleDegrees = (value) ->
  wrapToCap(value, 360)

wrapToCap = (value, cap) ->
  value %= cap
  if value < 0
    value += cap

  return value

normalizeVector = (vector, scalar = 1) ->
  [ x, y ] = vector
  normalizeCoordinates(x, y, scalar)

normalizeCoordinates = (x, y, scalar = 1) ->
  length = magnitude(x, y)
  [ x * scalar / length, y * scalar / length ]

# Does a linear interpolation between one range and another
# The first two arguments indicate the target range
# The second two arguments indicate the source range
# The final argument indicates the source value
linearInterpolate = (targetMin, targetMax, sourceMin, sourceMax, sourceProgress) ->
  sourceRange = sourceMax - sourceMin
  targetRange = targetMax - targetMin
  progress = (sourceProgress - sourceMin) / sourceRange
  progress * targetRange + targetMin

sample = (collection) ->
  collection[rand(collection.length)]

centroidOfSegments = (segments) ->
  xSum = 0
  ySum = 0
  for [x1, y1, x2, y2] in segments
    xSum += x1 + x2
    ySum += y1 + y2
  [ xSum / 2 / segments.length, ySum / 2 / segments.length ]

centroidOfRectangle = (rectangle) ->
  [ rectangle.width / 2 + rectangle.x, rectangle.height / 2 + rectangle.y ]

radiansDiff = (radians1, radians2) ->
  diff = radians2 - radians1
  sign = 1
  if diff < 0
    sign = -1
  size = Math.abs(diff)
  if size > PI
    size = TWO_PI - size
    sign = sign * -1

  size * sign

distance = (x1, y1, x2, y2) ->
  Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))

magnitude = (x, y) ->
  distance(0, 0, x, y)

snap = (x, precision) ->
  scaleUp = x * precision
  roundDown = Math.floor(scaleUp)
  roundUp   = Math.ceil(scaleUp)
  roundDownDelta = Math.abs(scaleUp - roundDown)
  roundUpDelta   = Math.abs(scaleUp - roundUp)

  if roundDownDelta < 1
    newX = roundDown
  else if roundUpDelta < 1
    newX = roundUp
  else
    newX = scaleUp

  newX / precision

@Math =
  PI_AND_A_HALF        : PI + PI / 2
  TWO_PI               : TWO_PI
  RAD_TO_DEG           : 180 / PI
  DEG_TO_RAD           : PI / 180
  random               : random
  rand                 : rand
  clamp                : clamp
  snap                 : snap
  wrapToCircle         : wrapToCircle
  wrapToCircleDegrees  : wrapToCircleDegrees
  normalizeVector      : normalizeVector
  normalizeCoordinates : normalizeCoordinates
  linearInterpolate    : linearInterpolate
  sample               : sample
  centroidOfSegments   : centroidOfSegments
  centroidOfRectangle  : centroidOfRectangle
  distance             : distance
  magnitude            : magnitude
  radiansDiff          : radiansDiff
