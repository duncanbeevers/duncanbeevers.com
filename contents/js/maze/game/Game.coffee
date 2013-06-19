BASE_BGM_VOLUME = 0.2

class @Game
  constructor: (canvas, preloader, hci) ->
    game = @
    createjs.Ticker.useRAF = true
    createjs.Ticker.setFPS(30)
    game._preloader = preloader

    stage = new createjs.Stage(canvas)

    sceneManager = new SceneManager(stage)

    game._hci = hci
    # Declare this early since its accessed by getSceneManager
    game._sceneManager = sceneManager

    tutorialScreen      = new TutorialScreen(game, hci)
    profilePickerScreen = new ProfilePickerScreen(game, hci)
    titleScreen         = new TitleScreen(game, hci)
    pauseMenu           = new PauseMenu(game, hci)

    sceneManager.addScene("tutorialScreen", tutorialScreen)
    sceneManager.addScene("profilePickerScreen", profilePickerScreen)
    sceneManager.addScene("titleScreen", titleScreen)
    sceneManager.addScene("pauseMenu", pauseMenu)


    sceneManager.gotoScene("profilePickerScreen")

    game._titleScreen = titleScreen

    updater = tick: -> stage.update()
    createjs.Ticker.addListener(updater)

  beginLevel: (levelData, profileName, profileData) ->
    sceneManager = @_sceneManager
    hci = @_hci

    level = new Level @, hci, levelData, (completionTime, wallImpactsCount, treasures) ->
      profileLevelsData = profileData.levels ||= {}
      profileLevelData = profileLevelsData[levelData.name] ||= {}
      profileLevelData.lastCompletionTime = completionTime
      previousBestCompletionTime = profileLevelData.bestCompletionTime || Infinity
      profileLevelData.bestCompletionTime = Math.min(previousBestCompletionTime, completionTime)

      profileLevelData.lastWallImpactsCount = wallImpactsCount
      previousBestWallImpactsCount = profileLevelData.bestWallImpactsCount || Infinity
      profileLevelData.bestWallImpactsCount = Math.min(previousBestWallImpactsCount, wallImpactsCount)

      treasuresCollected = profileLevelData.treasuresCollected ||= []
      for treasure, i in treasures
        if treasure.isCollected()
          treasuresCollected[i] = true
        else
          treasuresCollected[i] ||= false

      hci.saveProfile(profileName, profileData)

    sceneManager.addScene("level", level)
    sceneManager.pushScene("level")

  pause: () ->
    @_bgm.pause()
    createjs.Ticker.setPaused(true)

  unpause: () ->
    @_bgm.resume()
    createjs.Ticker.setPaused(false)

  setProfileData: (profileName, profileData) ->
    titleScreen = @_titleScreen
    titleScreen.setProfileData(profileName, profileData)

  returnToTitleScreen: ->
    @_sceneManager.gotoScene("titleScreen")

  setBgmTracks: (tracks) ->
    @_bgmTracks = tracks

  getSceneManager: ->
    @_sceneManager

  getPreloader: ->
    @_preloader

module.exports = Game
