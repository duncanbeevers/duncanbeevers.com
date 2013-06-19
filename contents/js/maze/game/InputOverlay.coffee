settings =
  cursorBlinkRate: 530

class @InputOverlay extends FW.ContainerProxy
  constructor: (hci, prompt, defaultValue, onSubmit, onDismiss) ->
    super()

    defaultValue ||= ""

    backdrop = setupBackdrop()
    gui = setupGui(prompt, defaultValue)
    cursor = setupCursor()

    @addChild(backdrop)
    @addChild(gui)
    @addChild(cursor)

    @_hci = hci
    @_onSubmit = onSubmit
    @_onDismiss = onDismiss
    @_backdrop = backdrop
    @_gui = gui
    @_cursor = cursor
    @_value = defaultValue
    @_cursorPosition = defaultValue.length

  onEnterScene: ->
    inputOverlay = @

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> onPressedLeft(inputOverlay) ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> onPressedRight(inputOverlay) ]

      [ "keyDown:#{FW.HCI.KeyMap.DELETE}", -> onPressedDelete(inputOverlay) ]
      [ "keyDown", (code) -> onPressedAnotherKey(inputOverlay, code) ]

      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> onPressedEnter(inputOverlay) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> onPressedEscape(inputOverlay) ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  onTick: ->
    super()

    stage = @getStage()
    return unless stage

    backdrop       = @_backdrop
    gui            = @_gui
    cursor         = @_cursor
    cursorPosition = @_cursorPosition
    value          = @_value

    canvas = stage.canvas

    backdrop.scaleX = canvas.width
    backdrop.scaleY = canvas.height

    xOffset = canvas.width / 2
    yOffset = canvas.height / 2
    gui.x = xOffset
    gui.y = yOffset

    gui.setValue(value)
    guiValueWidth = gui.getValueWidth(cursorPosition)

    cursor.scaleX = 4
    cursor.scaleY = 30
    cursor.x = xOffset + guiValueWidth / 2
    cursor.y = yOffset + 10

    blinkState = Math.floor(createjs.Ticker.getTime() / settings.cursorBlinkRate) % 2

    cursor.visible = blinkState

  getValue: ->
    return @_value

  setValue: (value) ->
    @_value = value
    length = value.length
    if @_cursorPosition > length
      @_cursorPosition = length

  getCursorPosition: ->
    return @_cursorPosition

  setCursorPosition: (cursorPosition) ->
    @_cursorPosition = cursorPosition

  submit: ->
    @_onSubmit(@_value)

  dismiss: ->
    @_onDismiss()

setupBackdrop = ->
  shape = new createjs.Shape()
  graphics = shape.graphics

  # 1x1 black half-opaque box, gets scaled to match screen size
  graphics.beginFill("rgba(0, 0, 0, 0.5)")
  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
  shape

setupGui = (prompt, defaultValue) ->
  container = new createjs.Container()

  promptText = TextFactory.create(prompt)
  promptText.y = -24

  inputText = TextFactory.create(defaultValue)
  inputText.y = 24

  container.addChild(promptText)
  container.addChild(inputText)

  container.setValue = (value) ->
    inputText.text = value

  container.getValueWidth = (cursorPosition) ->
    originalValue = inputText.text
    originalWidth = inputText.getMeasuredWidth()
    truncatedValue = originalValue.substr(0, cursorPosition)
    inputText.text = truncatedValue
    truncatedWidth = inputText.getMeasuredWidth()
    inputText.text = originalValue

    diff = originalWidth - truncatedWidth

    if inputText.textAlign == "center"
      diffScalar = 2
    else
      diffScalar = 1

    originalWidth - (diff * diffScalar)

  container

setupCursor = ->
  shape = new createjs.Shape()
  graphics = shape.graphics

  graphics.setStrokeStyle(0.25, "round", "bevel")
  graphics.beginFill("#FFFFFF")
  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
  shape.alpha = 0.5

  shape

onPressedEnter = (inputOverlay) ->
  inputOverlay.submit()

onPressedEscape = (inputOverlay) ->
  inputOverlay.dismiss()

onPressedDelete = (inputOverlay) ->
  value = inputOverlay.getValue()
  cursorPosition = inputOverlay.getCursorPosition()

  front = value.substring(0, cursorPosition - 1)
  back = value.substring(cursorPosition, value.length)

  newValue = front + back

  if newValue != value
    inputOverlay.setCursorPosition(cursorPosition - 1)
    inputOverlay.setValue(newValue)

onPressedLeft = (inputOverlay) ->
  value = inputOverlay.getValue()
  cursorPosition = inputOverlay.getCursorPosition()
  cursorPosition = FW.Math.clamp(cursorPosition - 1, 0, value.length)
  inputOverlay.setCursorPosition(cursorPosition)

onPressedRight = (inputOverlay) ->
  value = inputOverlay.getValue()
  cursorPosition = inputOverlay.getCursorPosition()
  cursorPosition = FW.Math.clamp(cursorPosition + 1, 0, value.length)
  inputOverlay.setCursorPosition(cursorPosition)

onPressedAnotherKey = (inputOverlay, code) ->
  string = FW.HCI.KeyMap.keyCodeToChar(code)

  value = inputOverlay.getValue()
  cursorPosition = inputOverlay.getCursorPosition()

  if string
    front = value.substring(0, cursorPosition)
    back = value.substring(cursorPosition, value.length)

    value = front + string + back

    inputOverlay.setCursorPosition(cursorPosition + 1)
    inputOverlay.setValue(value)
