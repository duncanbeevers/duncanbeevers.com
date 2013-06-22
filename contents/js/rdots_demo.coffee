floor = Math.floor
ceil = Math.ceil
random = Math.random

hsv2rgb = (h, s, v) ->
  h = h * 180 / Math.PI
  r = 0
  g = 0
  b = 0
  i = undefined
  f = undefined
  p1 = undefined
  p2 = undefined
  p3 = undefined
  map = undefined
  if s < 0
    s = 0
  else s = 1  if s > 1
  if v < 0
    v = 0
  else v = 1  if v > 1
  h %= 360
  h += 360  if h < 0
  h /= 60
  i = floor(h)
  f = h - i
  p1 = v * (1 - s)
  p2 = v * (1 - s * f)
  p3 = v * (1 - s * (1 - f))
  map = [[v, p3, p1], [p2, v, p1], [p1, v, p3], [p1, p2, v], [p3, p1, v], [v, p1, p2]]

  return [ map[i][0] * 255, map[i][1] * 255, map[i][2] * 255 ]


# Draws the requested block to the 2d context
drawBlock = (now, i, block_width, block_height, combined_size, columns, rows, context) ->
  col = floor(i / rows) % columns
  row = i % rows

  x = col * combined_size
  y = row * combined_size

  n = now / 2000
  hue        = ((col / columns) * Math.PI * 2 + n) % (Math.PI * 2)
  saturation = 1
  value      = (row / rows) * 0.5
  [ red, green, blue ] = hsv2rgb(hue, saturation, value)

  # opacity = (row / rows) * (col / columns)
  opacity = (row / rows) * (row / rows)
  fill_style = "rgba(#{floor(red)}, #{floor(green)}, #{floor(blue)}, #{opacity})"

  context.clearRect(col * combined_size, row * combined_size, block_width, block_height)
  context.fillStyle = fill_style
  context.beginPath()
  context.arc(x + block_width / 2, y + block_height / 2, Math.min(block_width, block_height) / 2, 0, Math.PI * 2, 0)
  context.fill()

fadeCanvas = (context, width, height) ->
  image_data = context.getImageData(0, 0, width, height)
  data = image_data.data
  for a, i in data by 4
    alpha = data[i + 3]
    data[i + 3] = ceil(alpha - 1, 0)

  context.putImageData(image_data, 0, 0)


block_size = 6
gutter_size = 8


tick = (ele, context, width, height, now) ->
  combined_size = block_size + gutter_size

  columns = floor(width / combined_size)
  rows = floor(height / combined_size)

  fadeCanvas(context, width, height)

  for [1..20]
    drawBlock(now, floor(random() * columns * rows), block_size, block_size, combined_size, columns, rows, context)

module.exports = tick
