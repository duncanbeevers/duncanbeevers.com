Maze.Structures.Substrate = $.extend {},
  initialize: ->
    # Okay, let's have some fun with this image
    substratePixelsPerMeter = @substratePixelsPerMeter ||= 1

    bitmap = @substrateBitmap

    image = bitmap.image
    # Underlying grid width and height
    imageWidth = image.width
    imageHeight = image.height
    width = Math.ceil(imageWidth / substratePixelsPerMeter) * @projection.columnWidth
    height = Math.ceil(imageHeight / substratePixelsPerMeter) * @projection.rowHeight
    @width = width
    @height = height

    # Blue dot is the start
    rect = FW.CreateJS.getFuzzyColorBoundsRect(bitmap, 0, 0, 255, 255, 60)
    if rect
      [x, y] = FW.Math.centroidOfRectangle(rect)
      x -= imageWidth / 2
      y -= imageHeight / 2

      @_initialIndex = @projection.infer(@, x / substratePixelsPerMeter, y / substratePixelsPerMeter)
    else
      throw("Couldn't find any blue-ish stuff to pick a starting index")

  initialIndex: ->
    @_initialIndex

  avoid: (maze, i) ->
    cache = @_substrateAvoidCache ||= []
    if cache[i] == undefined
      segments = maze.projection.project(maze, i, true)
      [ red, green, blue, alpha ] = FW.CreateJS.getColorWithinSegments(segments, @substrateBitmap)

      # Avoid transparent cells
      if alpha >= 128
        cache[i] = false
      else
        cache[i] = true

    cache[i]
