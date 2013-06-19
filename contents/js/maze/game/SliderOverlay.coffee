class @SliderOverlay extends FW.ContainerProxy
  constructor: (goPrev, goNext, goSelect) ->
    super()

    leftShape = new createjs.Shape()
    rightShape = new createjs.Shape()
    centerShape = new createjs.Shape()

    hitArea = new createjs.Shape()
    hitArea.graphics.beginFill("#000").drawRect(-0.5, -0.5, 1, 1).endFill()

    leftShape.hitArea = hitArea
    rightShape.hitArea = hitArea
    centerShape.hitArea = hitArea

    leftShape.addEventListener "press", goPrev
    rightShape.addEventListener "press", goNext
    centerShape.addEventListener "press", goSelect

    @addChild(leftShape)
    @addChild(rightShape)
    @addChild(centerShape)

    rightShape.rotation = 180

    @_harness     = FW.MouseHarness.outfit(@)
    @_leftShape   = leftShape
    @_rightShape  = rightShape
    @_centerShape = centerShape

  onTick: ->
    container = @
    stage = container.getStage()
    if stage
      sliderMargin = 1 / 3.8
      canvas       = stage.canvas
      canvasWidth  = canvas.width
      canvasHeight = canvas.height

      leftShape   = @_leftShape
      rightShape  = @_rightShape
      centerShape = @_centerShape

      leftShape.x = sliderMargin / 2
      leftShape.y = 0.5
      leftShape.scaleX = sliderMargin
      leftShape.scaleY = 1
      leftShape.regX = 0.5
      leftShape.regY = 0.5

      rightShape.x = 1 - sliderMargin / 2
      rightShape.y = 0.5
      rightShape.scaleX = sliderMargin
      rightShape.scaleY = 1
      rightShape.regX = 0.5
      rightShape.regY = 0.5

      centerShape.x = 0.5
      centerShape.y = 0.5
      centerShape.scaleX = 1 - (sliderMargin * 2)
      centerShape.scaleY = 1
      centerShape.regX = 0.5
      centerShape.regY = 0.5

      @scaleX = canvas.width
      @scaleY = canvas.height

      mouse = @_harness()

      leftShapeGraphics = leftShape.graphics
      rightShapeGraphics = rightShape.graphics

      if mouse.x < sliderMargin
        # Do something with the left one
        drawHoverOverlay(leftShapeGraphics)
        drawAtRestOverlay(rightShapeGraphics)
      else if mouse.x > 1 - sliderMargin
        # Do something with the right one
        drawAtRestOverlay(leftShapeGraphics)
        drawHoverOverlay(rightShapeGraphics)
      else
        drawAtRestOverlay(leftShapeGraphics)
        drawAtRestOverlay(rightShapeGraphics)

drawAtRestOverlay = (graphics) ->
  graphics.clear()

drawHoverOverlay = (graphics) ->
  graphics.clear()
  graphics.beginLinearGradientFill( [ "rgba(192,0,192,0.3)", "rgba(192,0,192,0)" ], [ 0, 0.25 ], 0, 0, 1, 0)
  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
