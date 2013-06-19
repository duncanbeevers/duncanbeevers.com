height = 48

class @TitleBox extends FW.ContainerProxy
  constructor: (title) ->
    super()

    background = new createjs.Shape()
    graphics = background.graphics
    graphics.setStrokeStyle(0.02, "round", "round")
    graphics.beginStroke("rgba(0, 0, 0, 0)")
    graphics.beginFill("rgba(192, 0, 192, 0.3)")

    graphics.drawRect(0, 0, 1, 1)
    graphics.endFill()
    graphics.endStroke()

    title ||= "Mazeoid"

    text = TextFactory.create(title, "#eee")
    text.textAlign = "left"
    text.textBaseline = "top"
    text.x = 64
    text.y = height / 2 - text.getMeasuredHeight() / 2 - 2

    logo = new createjs.Bitmap("images/Logo.png")
    logo.x = 4
    logo.y = 0

    @addChild(background)
    @addChild(text)
    @addChild(logo)

    @_background = background
    @_text = text

  setTitle: (title) ->
    @_text.text = title

  onTick: ->
    background = @_background

    canvas = @getStage().canvas
    background.scaleX = canvas.width
    background.scaleY = height
