class @LevelDetailsViewer extends FW.ContainerProxy
  constructor: ->
    levelDetailsViewer = @

    super()

    bestText                 = TextFactory.create("")
    bestCompletionTimeText   = TextFactory.create("")
    bestWallImpactsCountText = TextFactory.create("")
    treasuresTray            = new TreasuresTray()

    bestText.y                 = -36
    bestCompletionTimeText.y   = 0
    bestWallImpactsCountText.y = 36
    treasuresTray.y            = -72
    treasuresTray.scaleX       = 42
    treasuresTray.scaleY       = treasuresTray.scaleX

    levelDetailsViewer.addChild(bestText)
    levelDetailsViewer.addChild(bestCompletionTimeText)
    levelDetailsViewer.addChild(bestWallImpactsCountText)
    levelDetailsViewer.addChild(treasuresTray)

    levelDetailsViewer._bestText                 = bestText
    levelDetailsViewer._bestCompletionTimeText   = bestCompletionTimeText
    levelDetailsViewer._bestWallImpactsCountText = bestWallImpactsCountText
    levelDetailsViewer._treasuresTray            = treasuresTray

  setLevelData: (levelData) ->
    levelDetailsViewer = @
    levelDetailsViewer._levelData = levelData
    treasuresTray = levelDetailsViewer._treasuresTray
    treasures = Level.setupTreasures(levelData)

    treasuresTray.setTreasures(treasures)
    treasuresTray.centerRegX()

    levelDetailsViewer._treasures = treasures
    levelDetailsViewer.updateDisplay()

  setProfileData: (profileData) ->
    @_profileData = profileData
    @updateDisplay()

  updateDisplay: ->
    levelDetailsViewer = @

    levelData     = levelDetailsViewer._levelData
    profileData   = levelDetailsViewer._profileData
    treasuresTray = levelDetailsViewer._treasuresTray

    if levelData && profileData
      bestText                 = levelDetailsViewer._bestText
      bestCompletionTimeText   = levelDetailsViewer._bestCompletionTimeText
      bestWallImpactsCountText = levelDetailsViewer._bestWallImpactsCountText
      profileLevelsData        = profileData.levels || {}
      profileLevelData         = profileLevelsData[levelData.name]

      if profileLevelData
        treasuresCollected = profileLevelData.treasuresCollected || []
        for treasure, i in levelDetailsViewer._treasures
          if treasuresCollected[i]
            treasure.collected()

        bestCompletionTime   = profileLevelData.bestCompletionTime
        bestWallImpactsCount = profileLevelData.bestWallImpactsCount
        hitText              = TextFactory.pluralize("hit", bestWallImpactsCount)

        bestText.text                 = "Best"
        bestCompletionTimeText.text   = FW.Time.clockFormat(bestCompletionTime)
        bestWallImpactsCountText.text = bestWallImpactsCount + " " + hitText
      else
        bestText.text                 = "Begin"
        bestCompletionTimeText.text   = ""
        bestWallImpactsCountText.text = ""
