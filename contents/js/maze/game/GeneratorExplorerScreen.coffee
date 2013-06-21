merge = require("../../lib/merge.coffee")

FW_ContainerProxy = require("../FW/ContainerProxy.coffee").ContainerProxy
FW_CreateJS       = require("../FW/CreateJS.coffee").CreateJS
FW_Math           = require("../FW/Math.coffee").Math
createjs          = require("../../lib/easeljs-0.6.1.min.js")

Maze = require("../Maze/Maze.coffee").Maze;
CairoProjection           = require("../Maze/Projections/Cairo.coffee").Cairo
CairoStructure            = require("../Maze/Structures/Cairo.coffee").Cairo
CrossToothProjection      = require("../Maze/Projections/CrossTooth.coffee").CrossTooth
CrossToothStructure       = require("../Maze/Structures/CrossTooth.coffee").CrossTooth
FoldedHexagonProjection   = require("../Maze/Projections/FoldedHexagon.coffee").FoldedHexagon
FoldedHexagonStructure    = require("../Maze/Structures/FoldedHexagon.coffee").FoldedHexagon
GraphPaperProjection      = require("../Maze/Projections/GraphPaper.coffee").GraphPaper
GraphPaperStructure       = require("../Maze/Structures/GraphPaper.coffee").GraphPaper
HoneycombProjection       = require("../Maze/Projections/Honeycomb.coffee").Honeycomb
HoneycombStructure        = require("../Maze/Structures/Honeycomb.coffee").Honeycomb
SawToothProjection        = require("../Maze/Projections/SawTooth.coffee").SawTooth
SawToothStructure         = require("../Maze/Structures/SawTooth.coffee").SawTooth

choices = [
  -> [ CairoStructure,         new CairoProjection(),         8, 64 ]
  -> [ CrossToothStructure,    new CrossToothProjection(),    24, 96 ]
  -> [ FoldedHexagonStructure, new FoldedHexagonProjection(), 24, 24 ]
  -> [ GraphPaperStructure,    new GraphPaperProjection(),    24, 24 ]
  -> [ HoneycombStructure,     new HoneycombProjection,       24, 24 ]
  -> [ SawToothStructure,      new SawToothProjection(),      24, 48 ]
]

class @GeneratorExplorerScreen extends FW_ContainerProxy
  constructor: (game) ->
    @_game = game
    @_maxMagnitude = null
    super()

  onTick: ->
    stage = @parent
    offsetContainer = @_offsetContainer
    panningContainer = @_panningContainer
    mazeContainer = @_mazeContainer

    offsetContainer = @_offsetContainer
    canvasWidth = stage.canvas.width
    canvasHeight = stage.canvas.height
    halfCanvasWidth = canvasWidth / 2
    halfCanvasHeight = canvasHeight / 2

    offsetContainer.x = halfCanvasWidth
    offsetContainer.y = halfCanvasHeight

    canvasSize = Math.max(canvasWidth, canvasHeight)
    if @_completedTargetScale
      targetScale = @_completedTargetScale
      movementScalar = 1 / 10
    else
      targetScale = canvasSize / 15
      movementScalar = 1 / 150

    centroidOfLastDraw = @_centroidOfLastDraw
    scale = mazeContainer.scaleX + (targetScale - mazeContainer.scaleX) / 20
    mazeContainer.scaleX = scale
    mazeContainer.scaleY = scale

    if centroidOfLastDraw
      [ x, y ] = centroidOfLastDraw
      targetX = -x * scale
      targetY = -y * scale
      # panningContainer.x += (targetX - panningContainer.x) * movementScalar
      # panningContainer.y += (targetY - panningContainer.y) * movementScalar
      targetRotation = Math.atan2(y, x)
      rotation_diff = (targetRotation - mazeContainer.rotation * FW_Math.DEG_TO_RAD) / 20
      mazeContainer.rotation += rotation_diff
      mazeContainer.regX += (x - mazeContainer.regX) * movementScalar
      mazeContainer.regY += (y - mazeContainer.regY) * movementScalar
      mazeContainer.x = 0
      mazeContainer.y = 0


  onEnterScene: ->
    console.log("You entered the generator explorer scene")
    stage = @parent

    offsetContainer = new createjs.Container()
    panningContainer = new createjs.Container()
    mazeContainer = new createjs.Container()
    mazeShape = new createjs.Shape()

    mazeContainer.addChild(mazeShape)

    stage.addChild(offsetContainer)
    offsetContainer.addChild(panningContainer)
    panningContainer.addChild(mazeContainer)

    @_offsetContainer = offsetContainer
    @_panningContainer = panningContainer
    @_mazeContainer = mazeContainer
    @_mazeShape = mazeShape

    @reset()

  reset: ->
    screen = @
    @_centroidOfLastDraw = null
    @_completedTargetScale = null
    mazeContainer = @_mazeContainer
    mazeShape = @_mazeShape
    mazeGraphics = mazeShape.graphics
    mazeGraphics.clear()

    onMazeAvailable = (maze) ->
      canvas = mazeContainer.getStage().canvas
      canvasWidth = canvas.width
      canvasHeight = canvas.height
      canvasSize = Math.max(canvasWidth, canvasHeight)
      screen._completedTargetScale = canvasSize / (screen._maxMagnitude * 1.8) * 2
      screen._centroidOfLastDraw = [ 0, 0 ]
      reset = -> screen.reset()
      setTimeout(reset, 5000)
      # Something

    drawSegments = (color, segments) ->
      [_, _, _, _, _maxMagnitude] = FW_CreateJS.drawSegments(mazeGraphics, color, segments)
      maxMagnitude = Math.max(screen._maxMagnitude, _maxMagnitude)
      screen._maxMagnitude = maxMagnitude
      centroid = FW_Math.centroidOfSegments(segments)
      if centroid[0] && centroid[1]
        screen._centroidOfLastDraw = centroid

    maze_options =
      draw: (segments) -> drawSegments("rgba(0, 0, 0, 1)", segments)
      done: onMazeAvailable

    choice = do FW_Math.sample(choices)

    [ structure, projection, width, height ] = choice

    # Cairo
    maze_options = merge maze_options, structure,
      projection: projection
      width: width
      height: height

    Maze.createInteractive(maze_options)
