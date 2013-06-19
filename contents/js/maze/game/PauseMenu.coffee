class @PauseMenu extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    pausedTitle = setupPausedTitle()
    quitMaze = setupQuitMaze()

    @addChild(pausedTitle)
    @addChild(quitMaze)

    @_game = game
    @_hci = hci
    @_pausedTitle = pausedTitle
    @_quitMaze = quitMaze

  onEnterScene: ->
    pauseMenu = @

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}",  -> onPressedEnter(pauseMenu) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> onPressedEscape(pauseMenu) ]
      # [ "keyDown:#{FW.HCI.KeyMap.LEFT}",   -> profilePicker.selectPrevious() ]
      # [ "keyDown:#{FW.HCI.KeyMap.RIGHT}",  -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  onTick: ->
    super()

    stage = @getStage()
    return unless stage

    canvas = stage.canvas

    pausedTitle = @_pausedTitle
    quitMaze = @_quitMaze

    pausedTitle.x = canvas.width / 2
    pausedTitle.y = 48

    quitMaze.x = canvas.width / 2
    quitMaze.y = canvas.height - 48

setupPausedTitle = ->
  text = TextFactory.create("Paused")
  text

setupQuitMaze = ->
  container = new createjs.Container()

  text = TextFactory.create("Cowardly escape")
  text.x = 16


  backArrow = new createjs.Shape()
  graphics = backArrow.graphics
  graphics.setStrokeStyle("0.001", 0, 0)
  graphics.beginStroke("rgba(0,0,0,0)")
  graphics.beginFill("#ffffff")
  graphics.moveTo(0, 0.5)
  graphics.lineTo(1, 0)
  graphics.lineTo(1, 1)
  graphics.closePath()
  textMeasuredWidth = text.getMeasuredWidth()
  textMeasuredHeight = text.getMeasuredHeight()
  backArrow.x = -(textMeasuredWidth / 2) - 16
  backArrow.y = -(textMeasuredHeight / 2) + 6
  backArrow.scaleX = 24
  backArrow.scaleY = 32

  # TODO: Get this click thing working
  # Weirdly, not only does adding an onClick handler not seem to work,
  # but it prevents all other mouse input from working as well, cool!
  # hitArea = new createjs.Shape()
  # graphics = hitArea.graphics
  # graphics.beginFill("#ffffff")
  # graphics.drawRect(-0.5, -0.5, 1, 1)
  # hitArea.scaleX = textMeasuredWidth + 48
  # hitArea.scaleY = 48
  # container.hitArea = hitArea

  container.addChild(text)
  container.addChild(backArrow)

  container

onPressedEscape = (pauseMenu) ->
  sceneManager = pauseMenu._game.getSceneManager()
  sceneManager.popScene()

onPressedEnter = (pauseMenu) ->
  # Back to game, then tell Level to bail
  game = pauseMenu._game

  sceneManager = game.getSceneManager()
  sceneManager.popScene()

  game.returnToTitleScreen()
