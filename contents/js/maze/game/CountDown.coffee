class @CountDown extends FW.ContainerProxy
  constructor: (onComplete) ->
    super()

    @_onComplete = onComplete
    @_duration = 3000

    TextFactory.create()
    # text = new createjs.Text("Wonderful News!", "#FF4522", "36px Arial")
    # text = new createjs.Text("Wonderful News!", "#FF4522", "36px 04b_19")
    text = TextFactory.create("", "#04FAFF")

    # font-style font-variant font-weight font-size/line-height font-family"
    # text.font = "bold 48px Arial"

    @_text = text
    @_container.addChild(text)

  onTick: ->
    super()
    text = @_text
    canvas = @_container.getStage().canvas
    text.x = canvas.width / 2
    text.y = canvas.height / 2

    now = createjs.Ticker.getTime()
    if !@_startTime
      @_startTime = now
    elapsed = now - @_startTime
    duration = @_duration
    remaining = duration - elapsed

    intraSecondProgress = elapsed % 1000

    display = Math.floor((Math.min(remaining, duration - 1) / 1000) + 1)
    if display < 0
      @_container.removeChild(text)
      createjs.Ticker.removeListener(@)
      display = null
    else if display <= 0
      display = "Begin"
      if !@_onCompleteFired
        @_onCompleteFired = true
        @_onComplete?()

    if display
      text.text = display
      text.scaleX = FW.Math.linearInterpolate(2.5, 1, 0, 1000, intraSecondProgress)
      text.scaleY = text.scaleX
      text.alpha = FW.Math.linearInterpolate(1, 0.2, 0, 1000, intraSecondProgress)

  getCompleted: ->
    @_onCompleteFired