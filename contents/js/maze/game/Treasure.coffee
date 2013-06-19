settings =
  polyStarPointCountOffset: 1.3
  polyStarPointCountScalar: 1
  polyStarPointSize: 0.06

# FW.dat.GUI.addSettings(settings)

class @Treasure extends FW.ContainerProxy
  constructor: (numTreasures, index, seed) ->
    super()

    shape = new createjs.Shape()

    @addChild(shape)



    # Draw treasure shape
    graphics = shape.graphics
    points1  = (index / numTreasures) * settings.polyStarPointCountScalar + settings.polyStarPointCountOffset
    points2  = points1 + 0.3

    hsv1 = {
      h: 360 / numTreasures * index
      s: 1
      v: 0.7
    }
    hsv2 = {
      h: 360 / numTreasures * (index + 0.1)
      s: 1
      v: 0.6
    }
    rgb1 = FW.Util.hsv2rgb(hsv1)
    rgb2 = FW.Util.hsv2rgb(hsv2)
    color1 = "rgba(#{Math.floor(rgb1.r)},#{Math.floor(rgb1.g)},#{Math.floor(rgb1.b)},0.8)"
    color2 = "rgba(#{Math.floor(rgb2.r)},#{Math.floor(rgb2.g)},#{Math.floor(rgb2.b)},0.3)"

    graphics.clear()

    graphics.beginFill(color1)
    graphics.drawPolyStar(0, 0, 0.3, points1, settings.polyStarPointSize)
    graphics.endFill()

    graphics.beginFill(color2)
    graphics.drawPolyStar(0, 0, 0.3, points2, settings.polyStarPointSize, 90)
    graphics.endFill()



    # Assign instance variables
    @_numTreasures = numTreasures
    @_index        = index
    @_seed         = seed
    @_shape        = shape

  # For collisions
  name: "Treasure"

  onTick: ->
    super()

    # Position Treasure to physics body location,
    # if a physics fixture
    fixture = @fixture
    if fixture
      body     = fixture.GetBody()
      position = body.GetPosition()

      @x = position.x
      @y = position.y

    numTreasures = @_numTreasures
    index        = @_index
    shape        = @_shape
    seed         = @_seed
    advance = (FW.Math.wrapToCircleDegrees(seed) - 180) / 36
    @rotation = FW.Math.wrapToCircleDegrees(@rotation + advance)

  clone: ->
    numTreasures = @_numTreasures
    index        = @_index
    seed         = @_seed

    new Treasure(numTreasures, index, seed)

  collected: ->
    @_collected = true

  isCollected: ->
    @_collected