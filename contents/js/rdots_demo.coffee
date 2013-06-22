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
doBlock = (now, i, block_width, block_height, combined_size, columns, rows, context, draw) ->
  col = floor(i / rows) % columns
  row = i % rows

  x = col * combined_size
  y = row * combined_size

  n = now / 2000
  hue        = ((col / columns) * Math.PI * 2 + n) % (Math.PI * 2)
  saturation = 1
  value      = (row / rows) * 0.5
  [ red, green, blue ] = hsv2rgb(hue, saturation, value)


  context.clearRect(col * combined_size, row * combined_size, block_width, block_height)

  if draw
    opacity = (row / rows) * (row / rows)
    fill_style = "rgba(#{floor(red)}, #{floor(green)}, #{floor(blue)}, #{opacity})"

    context.fillStyle = fill_style
    context.beginPath()
    context.arc(x + block_width / 2, y + block_height / 2, Math.min(block_width, block_height) / 2, 0, Math.PI * 2, 0)
    context.fill()

drawBlock = (now, i, block_width, block_height, combined_size, columns, rows, context) ->
  doBlock(now, i, block_width, block_height, combined_size, columns, rows, context, true)

clearBlock = (now, i, block_width, block_height, combined_size, columns, rows, context) ->
  doBlock(now, i, block_width, block_height, combined_size, columns, rows, context, false)

fader_canvas = global.document.createElement("canvas")
fader_context = fader_canvas.getContext("2d")

fadeCanvas = (ele, context, width, height, changed) ->
  if changed
    fader_canvas.width = width
    fader_canvas.height = height

  original_alpha = context.globalAlpha
  fader_context.clearRect(0, 0, width, height)
  fader_context.drawImage(ele, 0, 0)
  context.globalAlpha = 0.95
  context.clearRect(0, 0, width, height)
  context.drawImage(fader_canvas, 0, 0)
  context.globalAlpha = original_alpha


block_size = 6
gutter_size = 8


tick = (ele, context, width, height, now, changed) ->
  combined_size = block_size + gutter_size

  columns = floor(width / combined_size)
  rows = floor(height / combined_size)

  fadeCanvas(ele, context, width, height, changed)

  for [1..20]
    clearBlock(now, floor(random() * columns * rows), block_size, block_size, combined_size, columns, rows, context)
  for [1..20]
    drawBlock(now, floor(random() * columns * rows), block_size, block_size, combined_size, columns, rows, context)

module.exports = tick
