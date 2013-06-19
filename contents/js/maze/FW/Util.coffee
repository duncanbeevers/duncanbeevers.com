FW = @FW ||= {}

mapToArraySortedByAttribute = (map, attribute, reverse) ->
  # Convert map to array
  unsortedResults = for key, value of map
    [ key, value ]

  # Sort the array by the provided attribute
  unsortedResults.sort (a, b) ->
    [ keyA, valueA ] = a
    [ keyB, valueB ] = b
    valA = valueA[attribute]
    valB = valueB[attribute]

    if reverse
      reverseScalar = -1
    else
      reverseScalar = 1

    # TODO: Generalize
    if valA < valB
      -1 * reverseScalar
    else if valA > valB
      1 * reverseScalar
    else
      0

indexOf = (collection, comparator) ->
  length = collection.length
  result = -1

  i = 0
  while i < length
    if comparator(collection[i])
      # Found it, break
      result = i
      i = length
    i += 1

  result

hsv2rgb = (hsv) ->
  h = hsv.h * 180 / Math.PI
  s = hsv.s
  v = hsv.v
  r = 0
  g = 0
  b = 0

  if s < 0
    s = 0
  else if s > 1
    s = 1

  if v < 0
    v = 0
  else if v > 1
    v = 1

  h %= 360
  if (h < 0)
    h += 360

  h /= 60;
  i = Math.floor(h)
  f = h - i
  p1 = v * (1 - s)
  p2 = v * (1 - s * f)
  p3 = v * (1 - s * (1 - f))

  map = [
    [ v, p3, p1 ]
    [ p2, v, p1 ]
    [ p1, v, p3 ]
    [ p1, p2, v ]
    [ p3, p1, v ]
    [ v, p1, p2 ]
  ]

  return {
     r: map[i][0] * 255
     g: map[i][1] * 255
     b: map[i][2] * 255
  }

FW.Util =
  mapToArraySortedByAttribute: mapToArraySortedByAttribute
  indexOf: indexOf
  hsv2rgb: hsv2rgb
