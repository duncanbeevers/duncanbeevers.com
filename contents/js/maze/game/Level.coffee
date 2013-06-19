settings =
  mazeRotationEase   : 100
  mazeZoomOutEase    : 6
  mazeZoomInEase     : 5
  mazePanEase        : 4
  playerPositionEase : 3
  playerRotationEase : 2
  timerTextEase      : 4
  solvedMazeRotationDelta: 0.01
  solvedMazeRotationEase: 1
  hud :
    impactTextScalar: 26.5
    textColor: "rgba(182,255,49,0.6)"
  motion:
    amplification: 7
    clamp: 0.5

# FW.dat.GUI.addSettings(settings)

maxViewportMeters = 6

class @Level extends FW.ContainerProxy
  constructor: (game, hci, mazeData, onMazeSolved) ->
    level = @

    super()

    levelContainer          = level._container
    mazeContainer           = new createjs.Container()
    player                  = new Player()
    goal                    = new Goal()
    impactParticleGenerator = new ImpactParticleGenerator()

    # The countdown timer gives us a moment to get our bearings
    # before beginning the maze.
    level._inProgress = false
    countDown = new CountDown -> level._inProgress = true

    timerText        = setupTimerText()
    impactsCountText = setupImpactsCountText()

    level.setupPhysics()

    treasures = setupTreasures(mazeData, level._world)
    treasuresTray = new TreasuresTray(treasures)

    mazeContainer.addChild(player)
    mazeContainer.addChild(goal)
    mazeContainer.addChild(impactParticleGenerator)
    for treasure in treasures
      mazeContainer.addChild(treasure)

    levelContainer.addChild(mazeContainer)
    levelContainer.addChild(countDown)
    levelContainer.addChild(timerText)
    levelContainer.addChild(impactsCountText)
    levelContainer.addChild(treasuresTray)

    level.setupMaze mazeData, mazeContainer, player, goal, -> level.onReady()

    level._game                    = game
    level._hci                     = hci
    level._onMazeSolved            = onMazeSolved
    level._mazeContainer           = mazeContainer
    level._player                  = player
    level._goal                    = goal
    level._impactParticleGenerator = impactParticleGenerator
    level._countDown               = countDown
    level._timerText               = timerText
    level._impactsCountText        = impactsCountText
    level._wallImpactsCount        = 0
    level._treasures               = treasures
    level._treasuresTray           = treasuresTray
    level._playerPositionStack     = [ ]

  onReady: ->
    # @_countDown.begin()
    # createjs.Ticker.addListener(@_countDown)

  setupPhysics: ->
    level = @

    contactListener = new FW.NamedContactListener()
    @_contactListener = contactListener

    world = new Box2D.Dynamics.b2World(
      new Box2D.Common.Math.b2Vec2(0, 0), # no gravity
      true                                # allow sleep
    )

    @_world = world

    world.SetContactListener(contactListener)

    maxImpactsPerWallPerSecond = 3
    minImpactInterval = 1000 / maxImpactsPerWallPerSecond

    # TODO: Make a directory, dynamically-loaded plinkplonk sounds
    # TODO: Differentiate sounds based on impact severity, plinks and PLONKS
    contactListener.registerContactListener "Wall", "Player", (impact, wallFixture, playerFixture) ->
      impactParticleGenerator = level._impactParticleGenerator

      # Throttle impact events per-wall
      wall           = wallFixture.GetUserData()
      lastImpactedAt = wall._lastImpactedAt || 0
      now            = FW.Time.now()

      # If the last impact event happened long-enough ago
      # register a new impact
      if now - lastImpactedAt > minImpactInterval
        wall._lastImpactedAt = now
        level._wallImpactsCount += 1

        # Play a sound
        src = FW.Math.sample([
          "sounds/plink1.mp3"
          "sounds/plink2.mp3"
          "sounds/plink3.mp3"
          "sounds/plink4.mp3"
          "sounds/plink5.mp3"
          "sounds/plonk1.mp3"
          "sounds/plonk2.mp3"
          "sounds/plonk3.mp3"
          "sounds/plonk4.mp3"
          "sounds/plonk5.mp3"
        ])
        createjs.SoundJS.play(src, createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, 1, 0)

        # Spawn an impact particle
        player = playerFixture.GetUserData()
        impactParticleGenerator.queueParticle(player.x, player.y)



    debugCanvas = document.getElementById("debugCanvas")
    if debugCanvas
      b2DebugDraw = Box2D.Dynamics.b2DebugDraw
      debugContext = debugCanvas.getContext("2d")
      debugDraw = new b2DebugDraw()
      @debugDraw = debugDraw
      debugDraw.SetSprite(debugContext)
      debugDraw.SetFillAlpha(1)
      debugDraw.SetLineThickness(1.0)
      debugDraw.SetFlags(
        b2DebugDraw.e_shapeBit        |
        # b2DebugDraw.e_jointBit        |
        # b2DebugDraw.e_aabbBit         |
        b2DebugDraw.e_centerOfMassBit |
        # b2DebugDraw.e_coreShapeBit    |
        # b2DebugDraw.e_jointBit        |
        # b2DebugDraw.e_obbBit          |
        # b2DebugDraw.e_pairBit         |
        0
      )
      world.SetDebugDraw(debugDraw)

    contactListener.registerContactListener "Player", "Goal", ->
      completionTime     = level.completionTime ||= createjs.Ticker.getTime(true)
      completionDuration = level.completionTime - level.startTime
      treasures          = level._treasures

      wallImpactsCount = level._wallImpactsCount
      level._inProgress = false
      level._onMazeSolved(completionDuration, wallImpactsCount, treasures)
      level._solved = true
      createjs.SoundJS.play("sounds/Goal1.mp3", createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, 1, 0)
      level._game.setBgmTracks(["sounds/GoalBGM1.mp3"])

    contactListener.registerContactListener "Player", "Treasure", (impact, playerFixture, treasureFixture) ->
      treasure = treasureFixture.GetUserData()
      treasure.collected()

      treasureSound = FW.Math.sample(["sounds/Treasure.mp3"])
      createjs.SoundJS.play(treasureSound, createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, 1, 0)


  onEnterScene: ->
    hci = @_hci
    level = @

    beginBacktrack = ->
      level.beginBacktrack()

    endBacktrack = ->
      level.endBacktrack()

    onUtilityKey = ->
      if level._solved
        level._game.getSceneManager().popScene()
      else
        onActivatedPauseMenu(level)

    @_hciSet = hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.SPACE}",  beginBacktrack ]
      [ "keyUp:#{FW.HCI.KeyMap.SPACE}",    endBacktrack ]
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}",  onUtilityKey ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", onUtilityKey ]
    )
    @_harness = FW.MouseHarness.outfit(@_mazeContainer)

  onLeaveScene: ->
    @_hciSet.off()

  setupMaze: (mazeData, mazeContainer, player, goal, onComplete) ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics

    pathShape        = new createjs.Shape()
    pathGlowShape    = new createjs.Shape()
    pathGraphics     = pathShape.graphics
    pathGlowGraphics = pathGlowShape.graphics

    onMazeDataAvailable = (mazeData, player, goal) ->
      positionPlayerAtBeginning(mazeData.start, player)
      positionGoalAtEnd(mazeData.end, goal)
      segments = mazeData.segments
      passages = mazeData.passages

      createPhysicsWalls(world, segments)
      createPhysicsPassages(world, passages)

      level.bounds = FW.CreateJS.drawSegments(mazeGraphics, "rgba(87, 21, 183, 0.3)", segments)
      level.walls = segments
      level.mazeGenerated = true

    positionPlayer = (start, player) ->
      [ player.x, player.y ] = start
      level._lastPlayerDot = new Box2D.Common.Math.b2Vec2(player.x, player.y)

    # Create physics entity

    positionPlayerAtBeginning = (maze, player) ->
      positionPlayer(maze, player)
      createPhysicsPlayer(world, player)

    positionGoalAtEnd = (end, goal) ->
      [ goal.x, goal.y ] = end
      createPhysicsGoal(world, goal)

    mazeContainer.addChild(mazeShape)
    mazeContainer.addChild(pathGlowShape)
    mazeContainer.addChild(pathShape)

    world = @_world
    level = @
    @_pathShape      = pathShape
    @_pathGlowShape  = pathGlowShape

    onMazeDataAvailable(mazeData, player, goal)
    # Invoke synchronously
    onComplete()

  onTick: ->
    level = @
    stage = level.getStage()
    return unless stage

    world               = level._world
    player              = level._player
    goal                = level._goal
    treasures           = level._treasures
    treasuresTray       = level._treasuresTray
    playerPositionStack = level._playerPositionStack
    everRanSimulation   = level._everRanSimulation
    timerText           = level._timerText
    impactsCountText    = level._impactsCountText

    if level._harness
      harness = level._harness()
      playerReticleTrackMouse(player, harness)
      levelTrackPlayer(level, player, harness)

      if level._inProgress
        if harness.activated
          if !level._backtracking
            level._mouseBacktracking = true
            level.beginBacktrack()
        else if level._mouseBacktracking
          level._mouseBacktracking = false
          level.endBacktrack()
      else if level._solved && harness.activated
        # Return to main title screen
        level._game.getSceneManager().popScene()
        return


    backtracking = level._backtracking

    runSimulation = level._inProgress && !backtracking
    if runSimulation
      level._everRanSimulation = true
      fps = createjs.Ticker.getFPS()
      level._world.Step(1 / fps, 10, 10)

    if backtracking
      if playerPositionStack.length
        [ player.x, player.y ] = playerPositionStack.pop()
      else
        level.endBacktrack()

    playerReticleTrackGoal(player, goal)

    if runSimulation
      playerTrackFixture(player)
      playerLeaveTrack(player, level)
      playerAccelerateTowardsTarget(player)

    if everRanSimulation
      updateTimer(timerText, impactsCountText, level)

    for treasure in treasures
      if treasure.isCollected() && treasure.fixture
        removeTreasure(world, treasure)

    updateTreasuresTray(treasuresTray, level)

    world.DrawDebugData()

  beginBacktrack: () ->
    @_backtracking = true

  endBacktrack: () ->
    @_backtracking = false
    @_drewAnyDots = false
    player = @_player
    body = player.fixture.GetBody()
    body.SetPosition(new Box2D.Common.Math.b2Vec2(player.x, player.y))
    @_lastPlayerDot.Set(player.x, player.y)

playerTrackFixture = (player) ->
  body = player.fixture.GetBody()
  position = body.GetPosition()

  player.x += (position.x - player.x) / settings.playerPositionEase
  player.y += (position.y - player.y) / settings.playerPositionEase


levelTrackPlayer = (level, player, harness) ->
  solved = level._solved
  mazeContainer = level._mazeContainer
  canvas = mazeContainer.getStage().canvas
  canvasWidth = canvas.width
  canvasHeight = canvas.height
  halfCanvasWidth = canvasWidth / 2
  halfCanvasHeight = canvasHeight / 2
  pixelsPerMeter = computePixelsPerMeter(level)
  xOffset = halfCanvasWidth / pixelsPerMeter - player.x
  yOffset = halfCanvasHeight / pixelsPerMeter - player.y
  debugDraw = level.debugDraw

  body = player.fixture.GetBody()
  position = body.GetPosition()

  currentRotation = FW.Math.wrapToCircle(mazeContainer.rotation * FW.Math.DEG_TO_RAD)

  if level._solved
    rotationEase = settings.solvedMazeRotationEase
    # scalar = (harness.stageX - halfCanvasWidth) / halfCanvasWidth

    targetRotation = 0
  else
    rotationEase = settings.mazeRotationEase
    targetRotation = Math.atan2(position.y, position.x)

  diff = FW.Math.radiansDiff(currentRotation, targetRotation)
  if !level._everTrackedPlayer
    # Initial rotation doesn't split different,
    # camera immediately orients to player position
    level._everTrackedPlayer = true
  else
    diff /= rotationEase

  if !debugDraw
    mazeContainer.rotation += diff * FW.Math.RAD_TO_DEG

  if solved
    [_, _, _, _, maxMagnitude] = level.bounds

    viewportScalar = 1.2
    scopedViewportWidth = canvasWidth / viewportScalar
    scopedViewportHeight = canvasHeight / viewportScalar

    regXOffset = canvasWidth - scopedViewportWidth
    regYOffset = canvasHeight - scopedViewportHeight

    targetScale = Math.min(
      canvasWidth * viewportScalar / (maxMagnitude * 2),
      canvasHeight * viewportScalar / (maxMagnitude * 2)
    )

    targetRegX = (harness.stageX - (canvasWidth / 2)) / targetScale
    targetRegY = (harness.stageY - (canvasHeight / 2)) / targetScale
  else
    velocity = body.GetLinearVelocity()
    velocityBoost = FW.Math.magnitude(velocity.x, velocity.y) / Math.min(canvasHeight, canvasWidth) * 500
    targetScale = pixelsPerMeter - velocityBoost
    targetRegX = player.x
    targetRegY = player.y


  if targetScale > mazeContainer.scaleX
    zoomEase = settings.mazeZoomInEase
  else
    zoomEase = settings.mazeZoomOutEase

  mazeContainer.scaleX += (targetScale - mazeContainer.scaleX) / zoomEase
  mazeContainer.scaleY = mazeContainer.scaleX
  mazeContainer.x = halfCanvasWidth
  mazeContainer.y = halfCanvasHeight
  mazePan = settings.mazePanEase
  mazeContainer.regX += (targetRegX - mazeContainer.regX) / mazePan
  mazeContainer.regY += (targetRegY - mazeContainer.regY) / mazePan

  if debugDraw
    scale = Math.max(mazeContainer.scaleX, 0)
    debugDraw.SetDrawScale(scale)
    debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(
      halfCanvasWidth / scale - mazeContainer.regX
      halfCanvasHeight / scale - mazeContainer.regY
    ))
    # debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(player.x, player.y))

playerReticleTrackMouse = (player, harness) ->
  # Align the thrust reticle graphic toward the mouse
  targetX = player.x - harness.x
  targetY = player.y - harness.y

  angleToMouse = Math.atan2(targetY, targetX)
  player.setThrustReticleAngle(angleToMouse)
  player.thrustTarget = [ targetX, targetY ]

playerAccelerateTowardsTarget = (player) ->
  body = player.fixture.GetBody()

  # Clear existing forces, then accelerate towards the target
  [ thrustX, thrustY ] = player.thrustTarget
  length = FW.Math.clamp(FW.Math.magnitude(thrustX, thrustY), 0, settings.motion.clamp) * settings.motion.amplification
  [ forceVectorX, forceVectorY ] = FW.Math.normalizeCoordinates(thrustX, thrustY, -length)

  forceVector = new Box2D.Common.Math.b2Vec2(forceVectorX, forceVectorY)
  body.SetLinearVelocity(forceVector)

playerReticleTrackGoal = (player, goal) ->
  # Align the goal reticle graphic towards the goal
  angleToGoal = Math.atan2(player.y - goal.y, player.x - goal.x)
  player.setGoalAngle(angleToGoal)

playerLeaveTrack = (player, level) ->
  # Leave a trail of dots!
  lastDot = level._lastPlayerDot
  lastDotDistance = FW.Math.distance(lastDot.x, lastDot.y, player.x, player.y)

  body = player.fixture.GetBody()
  velocity = body.GetLinearVelocity()
  magnitude = FW.Math.magnitude(velocity.x, velocity.y)
  moveDistance = Math.max(magnitude / 20, 0.01)

  if lastDotDistance > moveDistance
    position = body.GetPosition()
    level._playerPositionStack.push([ position.x, player.y ])

    pathGraphics = level._pathShape.graphics
    pathGlowGraphics = level._pathGlowShape.graphics
    if !level._drewAnyDots
      pathGraphics.endStroke()
      pathGraphics.beginStroke("rgba(0, 255, 255, 1)")
      pathGraphics.setStrokeStyle(0.02, "round", "round")
      pathGraphics.moveTo(lastDot.x, lastDot.y)

      pathGlowGraphics.endStroke()
      pathGlowGraphics.beginStroke("rgba(0, 255, 255, 0.4)")
      pathGlowGraphics.setStrokeStyle(0.08, "round", "round")
      pathGlowGraphics.moveTo(lastDot.x, lastDot.y)
      level._drewAnyDots = true

    pathGraphics.lineTo(player.x, player.y)
    pathGlowGraphics.lineTo(player.x, player.y)
    lastDot.Set(player.x, player.y)

computePixelsPerMeter = (level) ->
  mazeContainer = level._mazeContainer
  canvas = mazeContainer.getStage().canvas
  canvasWidth = canvas.width
  canvasHeight = canvas.height

  Math.min(canvasWidth / maxViewportMeters, canvasHeight / maxViewportMeters)

updateTimer = (timer, impactsCountText, level) ->
  now = createjs.Ticker.getTime(true)
  if !level.startTime
    level.startTime = now
  elapsed = (level.completionTime || now) - level.startTime
  canvas = timer.getStage().canvas

  solved = level._solved
  timer.text = FW.Time.clockFormat(elapsed)
  impactsCount = level._wallImpactsCount
  impactsCountText.text = impactsCount + " " + TextFactory.pluralize("hit", impactsCount)

  if solved
    targetX = canvas.width / 2
    targetY = canvas.height / 2 - (timer.scaleY * settings.hud.impactTextScalar / 2)
    targetScale = canvas.width / 210
  else
    targetX = canvas.width / 2
    targetY = 12
    targetScale = 0.5

  ease = settings.timerTextEase
  timer.x += (targetX - timer.x) / ease
  timer.y += (targetY - timer.y) / ease
  timer.scaleX += (targetScale - timer.scaleX) / ease
  timer.scaleY = timer.scaleX

  impactsCountText.x += (targetX - impactsCountText.x) / ease
  impactsCountText.y += ((targetY + timer.scaleY * settings.hud.impactTextScalar) - impactsCountText.y) / ease
  impactsCountText.scaleX += (targetScale - impactsCountText.scaleX) / ease
  impactsCountText.scaleY = impactsCountText.scaleX

updateTreasuresTray = (treasuresTray, level) ->
  canvas = treasuresTray.getStage().canvas
  canvasWidth = canvas.width
  canvasHeight = canvas.height
  scalar = canvasWidth / 12

  if level._solved
    targetX = canvasWidth / 2
    targetY = canvasHeight / 5
    treasuresTrayWidth = treasuresTray.width()
    targetScale = Math.min(canvasWidth / treasuresTrayWidth, canvasHeight / 4)
    targetRegX = (treasuresTrayWidth  - 1) / 2
  else
    targetX = canvasWidth / 24
    targetY = targetX
    targetScale = scalar
    targetRegX = 0

  treasuresTray.x += (targetX - treasuresTray.x) / 10
  treasuresTray.y += (targetY - treasuresTray.y) / 10
  treasuresTray.scaleX += (targetScale - treasuresTray.scaleX) / 10
  treasuresTray.scaleY = treasuresTray.scaleX
  treasuresTray.regX += (targetRegX - treasuresTray.regX) / 10


createPhysicsPlayer = (world, player) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef()
  fixtureDef.density = 1
  fixtureDef.friction = 0.1
  fixtureDef.restitution = 0.1
  diameter = 0.4
  fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(diameter / 4)
  bodyDef = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
  bodyDef.position.x = player.x
  bodyDef.position.y = player.y
  player.radius = diameter / 2
  player.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
  player.fixture.SetUserData(player)

createPhysicsGoal = (world, goal) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef()
  fixtureDef.density = 1
  fixtureDef.friction = 0.6
  fixtureDef.restitution = 0.1
  fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(0.25)
  bodyDef = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
  bodyDef.position.x = goal.x
  bodyDef.position.y = goal.y
  goal.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
  goal.fixture.SetUserData(goal)

createPhysicsPassages = (word, passages) ->

createPhysicsWalls = (world, segments) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef
  fixtureDef.density     = 1
  fixtureDef.friction    = 0.1
  fixtureDef.restitution = 0.2

  wallThickness = 0.1

  bodyDef      = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
  rectangle    = new Box2D.Collision.Shapes.b2PolygonShape()
  circle       = new Box2D.Collision.Shapes.b2CircleShape(wallThickness)

  for [x1, y1, x2, y2] in segments
    length = FW.Math.distance(x1, y1, x2, y2)
    rectangle.SetAsBox(length / 2, wallThickness)
    fixtureDef.shape = rectangle
    # Center rectangle
    bodyDef.position.Set((x2 - x1) / 2 + x1, (y2 - y1) / 2 + y1)
    bodyDef.angle = Math.atan2(y2 - y1, x2 - x1)
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"

    # Round caps
    bodyDef.position.Set(x1, y1)
    bodyDef.angle = 0
    fixtureDef.shape = circle
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"

    bodyDef.position.Set(x2, y2)
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"

createPhysicsTreasure = (world, treasure) ->

onActivatedPauseMenu = (level) ->
  level._game.getSceneManager().pushScene("pauseMenu")

setupTimerText = ->
  timerText = TextFactory.create("", settings.hud.textColor)

  timerText

setupImpactsCountText = ->
  impactsCountText = TextFactory.create("", settings.hud.textColor)

  impactsCountText

setupTreasures = (mazeData, world) ->
  terminations = mazeData.terminations
  # 0-1    : 0
  # 2-5    : 1
  # 6-24   : 2
  # 25-55  : 3
  # 55-100 : 4
  # 101+   : 5
  length = terminations.length
  if length <= 1
    numTreasures = 0
  else if length <= 5
    numTreasures = 1
  else if length <= 24
    numTreasures = 2
  else if length <= 55
    numTreasures = 3
  else if length <= 100
    numTreasures = 4
  else
    numTreasures = 5

  # Where will all the treasures go?
  terminationOffset = Math.ceil(length / numTreasures)

  treasures = for i in [0...numTreasures]
    termination = terminations[i * terminationOffset]
    setupTreasure(i, numTreasures, termination, world)

setupTreasure = (index, numTreasures, termination, world) ->
  [ x, y ] = termination

  seed = x + y
  treasure = new Treasure(numTreasures, index, seed)

  if world
    fixtureDef = new Box2D.Dynamics.b2FixtureDef()
    fixtureDef.density = 1
    fixtureDef.friction = 0.6
    fixtureDef.restitution = 0.1
    fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(0.25)
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
    bodyDef.position.x = x
    bodyDef.position.y = y
    treasure.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    treasure.fixture.SetUserData(treasure)

  treasure

removeTreasure = (world, treasure) ->
  world.DestroyBody(treasure.fixture.GetBody())
  # TODO: Fancy sparkle-out!
  treasure.visible = false
  treasure.fixture = undefined

Level.setupTreasures = setupTreasures
