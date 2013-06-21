merge = require("../../lib/merge.coffee")

FW_ContainerProxy = require("../FW/ContainerProxy.coffee").ContainerProxy
FW_CreateJS = require("../FW/CreateJS.coffee").CreateJS
FW_Math = require("../FW/Math.coffee").Math
createjs = require("../../lib/easeljs-0.6.1.min.js")

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

class @GeneratorExplorerScreen extends FW_ContainerProxy
  constructor: (game) ->
    @_game = game
    @_maxMagnitude = null
    super()

  onTick: ->
    stage = @parent
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
    else
      targetScale = canvasSize / 15

    centroidOfLastDraw = @_centroidOfLastDraw
    scale = mazeContainer.scaleX + (targetScale - mazeContainer.scaleX) / 20
    mazeContainer.scaleX = scale
    mazeContainer.scaleY = scale

    if centroidOfLastDraw
      targetX = -centroidOfLastDraw[0] * scale
      targetY = -centroidOfLastDraw[1] * scale
      panningContainer.x += (targetX - panningContainer.x) / 100
      panningContainer.y += (targetY - panningContainer.y) / 100


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
      canvasSize = Math.min(canvasWidth, canvasHeight)
      screen._completedTargetScale = canvasSize / (screen._maxMagnitude * 1.8)
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
      draw: (segments) -> drawSegments("rgba(0, 0, 0, 0.04)", segments)
      done: onMazeAvailable

    # Cairo
    maze_options = merge maze_options, CairoStructure,
      projection: new CairoProjection()
      width: 8
      height: 64

    Maze.createInteractive(maze_options)
