floor = Math.floor
random = Math.random
min = Math.min
max = Math.max
sqrt = Math.sqrt
clamp = (v, min_v, max_v) -> max(min(v, max_v), min_v)

drawLump = (context, width, height, now) ->
  pos_modulo = 32
  # x = (floor(random() * width / pos_modulo)) * pos_modulo
  # y = (floor(random() * height / pos_modulo)) * pos_modulo

  # x = floor((random() * width) % pos_modulo) * pos_modulo
  # y = floor((random() * height) % pos_modulo) * pos_modulo
  # x = floor(random() * width)
  # y = floor(random() * height)

  size_modulo = 16
  # size = floor(random() * min(width, height) / size_modulo) * size_modulo
  size = random() * min(width, height) / 5
  # size = 16
  # size = 2

  clamped_width = width - size * 2
  clamped_height = height - size * 2
  x = (now / width) % clamped_width + size;
  y = (Math.sin(now / 400) * clamped_height / 2) + height / 2


  # Snag a piece of the context image data, but don't step over the bounds
  rect_x1 = floor(max(0, x - size))
  rect_x2 = floor(min(width, x + size))
  rect_y1 = floor(max(0, y - size))
  rect_y2 = floor(min(height, y + size))
  rect_width = rect_x2 - rect_x1
  rect_height = rect_y2 - rect_y1

  return unless rect_width && rect_height

  image_data = context.getImageData(rect_x1, rect_y1, rect_width, rect_height)
  data = image_data.data

  reverse = (floor(random() * 2) == 0)

  displacement_range_min = 16
  displacement_range_max = 32

  displacement_scalar = (random() * (displacement_range_max - displacement_range_min)) + displacement_range_min

  if reverse
    displacement_scalar *= -1

  for data_y in [0...rect_height]
    for data_x in [0...rect_width]
      i = (data_y * rect_width + data_x) * 4

      x_dist = x - data_x - rect_x1
      y_dist = y - data_y - rect_y1

      dist = sqrt(y_dist * y_dist + x_dist * x_dist)

      red   = data[i]
      green = data[i]
      blue  = data[i]
      alpha = data[i + 3]

      grade = 1 - (dist / size)
      displacement = grade * displacement_scalar

      if dist <= size
        red   -= displacement
        green -= displacement
        blue  += displacement
        alpha += displacement

      data[i] = floor(clamp(red, 0, 255))
      data[i + 1] = floor(clamp(green, 0, 255))
      data[i + 2] = floor(clamp(blue, 0, 255))
      data[i + 3] = floor(clamp(alpha, 0, 255))

  context.putImageData(image_data, rect_x1, rect_y1)


tick = (ele, context, width, height, now) ->
  drawLump(context, width, height, now)

module.exports = tick