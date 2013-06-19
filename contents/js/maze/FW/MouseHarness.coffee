FW = @FW ||= {}

harness_x = 0
harness_y = 0
harness_activated = false

FW.MouseHarness =
  outfit: (displayObject) ->
    if displayObject._outfittedMouseHarness
      return displayObject._outfittedMouseHarness

    stage = displayObject.getStage()
    outfitStage(stage)

    harness = ->
      outfitStage(displayObject.getStage())
      point = displayObject.globalToLocal(harness_x, harness_y)
      x: point.x
      y: point.y
      stageX: harness_x
      stageY: harness_y
      activated: harness_activated

    displayObject._outfittedMouseHarness = harness
    harness

outfitStage = (stage) ->
  if !stage
    return

  if stage._outfittedWithMouseHarness
    return

  stage._outfittedWithMouseHarness = true

  stage.addEventListener "mouseDown", (event) ->
    harness_activated = true
    harness_x = event.stageX
    harness_y = event.stageY

  stage.addEventListener "mouseUp", (event) ->
    harness_activated = false
    harness_x = event.stageX
    harness_y = event.stageY

  stage.addEventListener "mouseMove", (event) ->
    harness_x = event.stageX
    harness_y = event.stageY
