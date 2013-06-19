createjs = @createjs

$ ->
  maze = null
  $type = $("#type")

  onTypeChange = ->
    type = $type.val()
    $(".config:not(.#{type})").hide()
    $(".config.#{type}").show()
    $(".config.Global").show()

  updateStatus = (status, disable) ->
    $("#status_text").text(status)
    $("button,select").attr("disabled", !!disable)

  updateInfo = (maze) ->
    if maze.terminations
      info =
        terminations: maze.terminations.length
        maxLength: maze.maxTermination[1]
      text = JSON.stringify(info)
    else
      text = ""

    $("#info").text(text)

  $canvas = $("#generatorCanvas")
  $canvas.attr(width: "500", height: "500")
  stage = new createjs.Stage($canvas[0])
  mazeContainer = new createjs.Container()

  mazeShape = new createjs.Shape()
  mazeGraphics = mazeShape.graphics

  mazeContainer.addChild(mazeShape)
  stage.addChild(mazeContainer)

  canvasWidth = stage.canvas.width
  canvasHeight = stage.canvas.height
  halfCanvasWidth = canvasWidth / 2
  halfCanvasHeight = canvasHeight / 2

  mazeContainer.x = halfCanvasWidth
  mazeContainer.y = halfCanvasHeight

  substrateContainer = new createjs.Container()
  mazeContainer.addChildAt(substrateContainer, 0)

  onMazeAvailable = (maze) ->
    updateStatus("Ready")
    updateInfo(maze)

  onSegmentsJoined = (segments) ->
    updateStatus("Ready")
    maze.joinedSegments = segments

    mazeGraphics.clear()
    drawSegments("#46083D", segments)

  maxMagnitude = null
  targetScale = null
  resetBoundaries = ->
    maxMagnitude = -Infinity
    targetScale = 1

  drawSegments = (color, segments) ->
    canvas = mazeContainer.getStage().canvas
    canvasWidth = canvas.width
    canvasHeight = canvas.height
    canvasSize = Math.min(canvasWidth, canvasHeight)
    canvasSize -= canvasSize / 15

    [_, _, _, _, _maxMagnitude] = FW.CreateJS.drawSegments(mazeGraphics, color, segments)
    maxMagnitude = Math.max(maxMagnitude, _maxMagnitude)
    targetScale = canvasSize / (maxMagnitude * 2)

  generateMaze = (type, options) ->
    resetBoundaries()
    mazeGraphics.clear()
    substrateContainer.removeAllChildren()

    status = "Generating"
    disable = true

    # Define maze options common to all mazes
    mazeOptions = $.extend {}, options || {},
      draw: (segments) -> drawSegments("rgba(33, 153, 255, 0.5)", segments)
      done: onMazeAvailable

    next = ->
      maze = Maze.createInteractive(mazeOptions)

    switch type
      when "GraphPaper"
        $.extend mazeOptions, Maze.Structures.GraphPaper,
          projection: new Maze.Projections.GraphPaper()

      when "FoldedHexagon"
        size = Math.floor((mazeOptions.size + 1) / 2) * 2
        $.extend mazeOptions, Maze.Structures.FoldedHexagon,
          projection: new Maze.Projections.FoldedHexagonCell()
          width: size
          height: size

      when "SawTooth"
        height = Math.floor((mazeOptions.height + 1) / 2) * 2
        $.extend mazeOptions, Maze.Structures.SawTooth,
          projection: new Maze.Projections.SawTooth()
          peakAngle: 60
          height: height

      when "CrossTooth"
        height = Math.floor((mazeOptions.height + 3) / 4) * 4
        $.extend mazeOptions, Maze.Structures.CrossTooth,
          projection: new Maze.Projections.CrossTooth()
          height: height

      when "Honeycomb"
        $.extend mazeOptions, Maze.Structures.Honeycomb,
          projection: new Maze.Projections.Honeycomb()

      when "Cairo"
        $.extend mazeOptions, Maze.Structures.Cairo,
          projection: new Maze.Projections.Cairo()

      when "Substrate"
        switch mazeOptions.projectionName
          when "GraphPaper"
            structure = Maze.Structures.GraphPaper
            projection = new Maze.Projections.GraphPaper()
          when "SawTooth"
            structure = Maze.Structures.SawTooth
            projection = new Maze.Projections.SawTooth()
          when "CrossTooth"
            structure = Maze.Structures.CrossTooth
            projection = new Maze.Projections.CrossTooth()
          when "Honeycomb"
            structure = Maze.Structures.Honeycomb
            projection = new Maze.Projections.Honeycomb()
          when "Cairo"
            structure = Maze.Structures.Cairo
            projection = new Maze.Projections.Cairo()

        $.extend mazeOptions, Maze.Structures.Substrate,
          structure, projection: projection

        createMaze = next
        imageUrl = mazeOptions.imageUrl

        next = ->
          preloader = new createjs.PreloadJS()
          preloader.onComplete = ->
            bitmap = new createjs.Bitmap(imageUrl)
            bitmap.regX = bitmap.image.width / 2
            bitmap.regY = bitmap.image.height / 2
            bitmap.scaleX = 1 / mazeOptions.substratePixelsPerMeter
            bitmap.scaleY = bitmap.scaleX

            mazeOptions.substrateBitmap = bitmap
            substrateContainer.addChild(bitmap)
            createMaze()

          preloader.loadManifest([ imageUrl ])

      else
        status = "Unknown maze type: #{type}"
        disable = false

    updateStatus(status, disable)
    if disable
      next()


  # Register event handlers
  $("#serialize").on "click", ->
    $("#serialized").text(JSON.stringify(maze.serialize()))

  $("#png").on "click", ->
    data = $canvas[0].toDataURL()
    $("#serialized").text(data)
    $("#serialized").append("<img src=\"#{data}\" alt=\"\" \>")

  $type.on "change", onTypeChange

  $("#Substrate_displaySubstrateImage").on "change", (event) ->
    if $(event.target).is(":checked")
      substrateContainer.visible = true
    else
      substrateContainer.visible = false


  $("#generate").on "click", ->
    options = {}

    type = $type.val()

    selectors = []
    types = [ type, "Global" ]
    tags = [ "input", "select" ]
    for configType in types
      for tag in tags
        selectors.push(".config.#{configType} #{tag}")

    inputs = $(selectors.join(","))
    for input in inputs
      $input = $(input)
      val = $input.val()
      if $input.attr("type") == "number"
        val = +val

      options[$input.attr("name")] = val

    generateMaze(type, options)

  $("#optimize").on "click", ->
    if maze.projectedSegments
      updateStatus("Joining segments", true)
      joiner = new Maze.SegmentJoiner(maze.projectedSegments)
      joiner.solve(onSegmentsJoined)
    else
      updateStatus("No maze generated")

  # Set up initial state
  updateStatus("Ready", false)
  onTypeChange()

  createjs.Ticker.addListener tick: ->
    mazeContainer.scaleX += (targetScale - mazeContainer.scaleX) / 10
    mazeContainer.scaleY = mazeContainer.scaleX
    stage.update()
