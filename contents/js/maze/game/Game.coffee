createjs = require("../../lib/easeljs-0.6.1.min.js")
SceneManager = require("./SceneManager.coffee").SceneManager
GeneratorExplorerScreen = require("./GeneratorExplorerScreen.coffee").GeneratorExplorerScreen

BASE_BGM_VOLUME = 0.2

class @Game
  constructor: (canvas) ->
    game = @

    stage = new createjs.Stage(canvas)

    sceneManager = new SceneManager(stage)

    # Declare this early since its accessed by getSceneManager
    game._sceneManager = sceneManager

    generatorExplorerScreen = new GeneratorExplorerScreen(game)
    sceneManager.addScene("generatorExplorer", generatorExplorerScreen)


    sceneManager.gotoScene("generatorExplorer")

    this.tick = -> stage.update()

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

  tick: ->
