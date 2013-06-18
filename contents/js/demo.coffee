# Get the moment, controls clock rate
getNow = -> floor(new Date())

# Memoize reference to demo canvas element
getEle = do ->
  ele = null
  ->
    if ele
      return ele
    else
      eles = document.getElementsByClassName("demo")
      ele = eles[0]

# Memoize the 2d context of the demo canvas element
getContext = do ->
  context = null
  (ele) ->
    return unless ele
    context ||= ele.getContext("2d")

# shorthand function refences
requestAnimationFrame = window.requestAnimationFrame
getComputedStyle      = window.getComputedStyle
ceil                  = Math.ceil
floor                 = Math.floor
random                = Math.random

# Note the start time of the script
start = getNow()

onTick = ->
  # Reschedule onTick
  requestAnimationFrame(onTick)

  # Try and get element and 2d context
  ele = getEle()
  context = getContext(ele)

  # Wait until next tick if we couldn't get them
  return unless ele && context

  # Demo resolution equals rendered dimensions
  ele_computed_style = getComputedStyle(ele)
  # par_computed_style = getComputedStyle(ele.parentNode)
  # doc_computed_style = getComputedStyle(document.body)

  ele_width = parseInt(ele_computed_style.width, 10)
  ele_height = parseInt(ele_computed_style.height, 10)
  # par_width = parseInt(par_computed_style.width, 10)
  # doc_width = parseInt(doc_computed_style.width, 10)

  # gutters_width = doc_width - par_width
  # gutter_width = floor(gutters_width / 2)

  # ele.style.left = "-#{gutter_width}px"
  # ele.style.width = "#{doc_width}px"

  width = ele_width
  height = ele_height

  # If the computed size of the element changed,
  # apply the values literally
  if ele.width != width || ele.height != height
    ele.width = width
    ele.height = height

  block_size = 6
  gutter_size = 8
  combined_size = block_size + gutter_size

  columns = floor(width / combined_size)
  rows = floor(height / combined_size)

  # i = (getNow() - start) % (columns * rows)
  # drawBlock(i, block_size, combined_size, columns, rows, context)

  # for _ in [1..10]
  # drawBlock(false, floor(random() * columns * rows), block_size, block_size, combined_size, columns, rows, context)
  drawBlock(false, 0, width, height, 0, 1, 1, context)

  for _ in [1..20]
    drawBlock(true, floor(random() * columns * rows), block_size, block_size, combined_size, columns, rows, context)


# Draws the requested block to the 2d context
drawBlock = (perform_draw, i, block_width, block_height, combined_size, columns, rows, context) ->
  col = floor(i / rows) % columns
  row = i % rows

  x = col * combined_size
  y = row * combined_size

  if perform_draw
    now = getNow()
    n = now / 2000
    hue        = ((col / columns) * Math.PI * 2 + n) % (Math.PI * 2)
    saturation = 1
    value      = (row / rows) * 0.5
    [ red, green, blue ] = hsv2rgb(hue, saturation, value)

    # opacity = (row / rows) * (col / columns)
    opacity = (row / rows)
    fill_style = "rgba(#{floor(red)}, #{floor(green)}, #{floor(blue)}, #{opacity})"

    context.clearRect(col * combined_size, row * combined_size, block_width, block_height)
    context.fillStyle = fill_style
    context.beginPath()
    context.arc(x + block_width / 2, y + block_height / 2, Math.min(block_width, block_height) / 2, 0, Math.PI * 2, 0)
    context.fill()
    # context.fillRect(x, y, block_width, block_height)
  else
    image_data = context.getImageData(x, y, block_width, block_height)
    data = image_data.data
    for a, i in image_data.data by 4
      alpha = data[i + 3]
      data[i + 3] = ceil(alpha - 1, 0)

    context.putImageData(image_data, x, y)



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
  i = Math.floor(h)
  f = h - i
  p1 = v * (1 - s)
  p2 = v * (1 - s * f)
  p3 = v * (1 - s * (1 - f))
  map = [[v, p3, p1], [p2, v, p1], [p1, v, p3], [p1, p2, v], [p3, p1, v], [v, p1, p2]]

  return [ map[i][0] * 255, map[i][1] * 255, map[i][2] * 255 ]




# Kick off the first draw
requestAnimationFrame(onTick)
