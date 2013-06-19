class @TreasuresTray extends FW.ContainerProxy
  constructor: (originalTreasures) ->
    super()

    treasuresTray = @

    trayContainer = new createjs.Container()
    treasuresTray.addChild(trayContainer)

    treasuresTray._trayContainer = trayContainer

    if originalTreasures
      treasuresTray.setTreasures(originalTreasures)

  setTreasures: (originalTreasures) ->
    numTreasures = originalTreasures.length

    treasuresTray = @

    trayContainer = treasuresTray._trayContainer
    trayContainer.removeAllChildren()

    treasures = for originalTreasure in originalTreasures
      originalTreasure.clone()

    for treasure, i in treasures
      trayContainer.addChild(treasure)
      treasure.x = i

    treasuresTray._originalTreasures = originalTreasures
    treasuresTray._treasures = treasures


  onTick: ->
    super()

    originalTreasures = @_originalTreasures
    treasures = @_treasures

    for treasure, i in treasures
      if originalTreasures[i].isCollected()
        targetAlpha = 1
        targetScale = 1
      else
        targetAlpha = 0.2
        targetScale = 0.8

      treasure.alpha += (targetAlpha - treasure.alpha) / 10
      treasure.scaleX += (targetScale - treasure.scaleX) / 10
      treasure.scaleY = treasure.scaleX

  width: ->
    treasuresTray = @
    treasuresTray._treasures.length

  centerRegX: ->
    treasuresTray = @
    treasuresTray.regX = (treasuresTray._treasures.length - 1) / 2
