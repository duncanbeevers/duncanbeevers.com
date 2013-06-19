class @TitleScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()
    screen = @

    preloader = game.getPreloader()

    titleBox = new TitleBox()
    levelPicker = setupLevelPicker(screen, preloader.getLevels(), hci)
    levelDetailsViewer = setupLevelDetailsViewer(screen)
    sliderOverlay = setupSliderOverlay(screen, game, levelPicker, levelDetailsViewer)

    screen.addChild(levelPicker)
    screen.addChild(titleBox)
    screen.addChild(levelDetailsViewer)
    screen.addChild(sliderOverlay)

    @_game               = game
    @_hci                = hci
    @_titleBox           = titleBox
    @_levelPicker        = levelPicker
    @_levelDetailsViewer = levelDetailsViewer

  onEnterScene: ->
    game               = @_game
    levelPicker        = @_levelPicker
    levelDetailsViewer = @_levelDetailsViewer
    sceneManager       = game.getSceneManager()

    screen = @
    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> onPressedEnter(screen, game, levelPicker) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> sceneManager.popScene() ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> selectPreviousLevel(levelPicker, levelDetailsViewer) ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> selectNextLevel(levelPicker, levelDetailsViewer) ]
    )

    levelDetailsViewer.setLevelData(levelPicker.currentLevelData())

  onLeaveScene: ->
    @_hciSet.off()

  setProfileData: (profileName, profileData) ->
    profileData.lastLoadedAt = FW.Time.now()
    @_profile                = [ profileName, profileData ]
    titleBox                 = @_titleBox
    levelDetailsViewer       = @_levelDetailsViewer
    hci                      = @_hci

    titleBox.setTitle(profileName)
    levelDetailsViewer.setProfileData(profileData)
    hci.saveProfile(profileName, profileData)

  onTick: ->
    stage = @getStage()
    if stage
      canvas = stage.canvas
      levelDetailsViewer = @_levelDetailsViewer
      levelDetailsViewer.x = canvas.width / 2
      levelDetailsViewer.y = canvas.height / 3 + canvas.height / 2

setupLevelPicker = (screen, levels, hci) ->
  initialLevelIndex = 0
  levelPicker = new LevelPicker(levels, initialLevelIndex)

  levelPicker.addEventListener "tick", ->
    levelsVisibleOnScreen = 3.5

    canvas = screen.getStage().canvas
    levelPicker.scaleX = canvas.width / levelsVisibleOnScreen
    levelPicker.scaleY = levelPicker.scaleX

    levelPicker.x = canvas.width / 2
    levelPicker.y = canvas.height / 3

  levelPicker

setupLevelDetailsViewer = (screen) ->
  new LevelDetailsViewer()

setupSliderOverlay = (screen, game, levelPicker, levelDetailsViewer) ->
  goPrev = -> selectPreviousLevel(levelPicker, levelDetailsViewer)
  goNext = -> selectNextLevel(levelPicker, levelDetailsViewer)
  goSelect = -> onPressedEnter(screen, game, levelPicker)
  overlay = new SliderOverlay(goPrev, goNext, goSelect)
  overlay

onPressedEnter = (screen, game, levelPicker) ->
  [ profileName, profileData ] = screen._profile
  game.beginLevel(levelPicker.currentLevelData(), profileName, profileData)

selectPreviousLevel = (levelPicker, levelDetailsViewer) ->
  levelPicker.selectPrevious()
  levelDetailsViewer.setLevelData(levelPicker.currentLevelData())

selectNextLevel = (levelPicker, levelDetailsViewer) ->
  levelPicker.selectNext()
  levelDetailsViewer.setLevelData(levelPicker.currentLevelData())

