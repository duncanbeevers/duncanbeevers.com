merge = require("../../lib/merge.coffee")

FW_ContainerProxy = require("../FW/ContainerProxy.coffee").ContainerProxy
FW_CreateJS = require("../FW/CreateJS.coffee").CreateJS
createjs = require("../../lib/easeljs-0.6.1.min.js")

Maze = require("../Maze/Maze.coffee").Maze;
CairoProjection = require("../Maze/Projections/Cairo.coffee").Cairo
CairoStructure = require("../Maze/Structures/Cairo.coffee").Cairo

class @GeneratorExplorerScreen extends FW_ContainerProxy
  constructor: (game) ->
    @_game = game

  onEnterScene: ->
    console.log("You entered the generator explorer scene")

    onMazeAvailable = (maze) ->
      debugger

    drawSegments = (color, segments) ->
      canvas = mazeContainer.getStage().canvas
      canvasWidth = canvas.width
      canvasHeight = canvas.height
      canvasSize = Math.min(canvasWidth, canvasHeight)
      canvasSize -= canvasSize / 15

      [_, _, _, _, _maxMagnitude] = FW_CreateJS.drawSegments(mazeGraphics, color, segments)
      maxMagnitude = Math.max(maxMagnitude, _maxMagnitude)
      targetScale = canvasSize / (maxMagnitude * 2)

    projection = new CairoProjection()
    structure = CairoStructure;
    maze_options =
      draw: (segments) -> drawSegments("rgba(33, 153, 255, 0.5)", segments)
      done: onMazeAvailable

    maze_options = merge(maze_options, structure, projection: projection)

    stage = @parent
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


    Maze.createInteractive(maze_options)
