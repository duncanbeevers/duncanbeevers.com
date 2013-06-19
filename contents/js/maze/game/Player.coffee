class @Player extends FW.ParticleGenerator
  constructor: ->
    super()

    radius = 0.25
    arrowWidth = radius / 2
    halfArrowWidth = arrowWidth / 2
    arrowHeight = halfArrowWidth

    thrustReticle = new createjs.Shape()
    @thrustReticle = thrustReticle
    graphics = thrustReticle.graphics
    graphics.clear()
    graphics.beginStroke("rgba(192, 0, 192, 0.5)")
    graphics.beginFill("rgba(192, 0, 192, 0.5)")
    graphics.setStrokeStyle(0.01, "round", "bevel")
    graphics.moveTo(-radius, -halfArrowWidth)
    graphics.lineTo(-radius - arrowHeight, 0)
    graphics.lineTo(-radius, halfArrowWidth)
    graphics.lineTo(-radius, -halfArrowWidth)
    graphics.endStroke()
    graphics.endFill()
    @addChild(thrustReticle)

    radius += 0.1
    goalReticle = new createjs.Shape()
    @goalReticle = goalReticle
    graphics = goalReticle.graphics
    graphics.clear()

    graphics.setStrokeStyle(0.055, "round", "bevel")
    graphics.beginStroke("rgba(0, 3, 79, 0.5)")
    graphics.arc(0, 0, radius, Math.PI - 0.2, Math.PI + 0.2)
    graphics.endStroke()

    graphics.setStrokeStyle(0.05, "round", "bevel")
    graphics.beginStroke("rgba(4, 51, 119, 0.5)")
    graphics.arc(0, 0, radius + 0.08, Math.PI - 0.2, Math.PI + 0.2)
    graphics.endStroke()

    graphics.setStrokeStyle(0.045, "round", "bevel")
    graphics.beginStroke("rgba(33, 153, 255, 0.5)")
    graphics.arc(0, 0, radius + 0.16, Math.PI - 0.2, Math.PI + 0.2)
    graphics.endStroke()

    @addChild(goalReticle)

  # Collision name
  name: "Player"

  # ParticleEmitter properties
  maxParticles: 100
  absolutePlacement: true

  numberOfParticlesToGenerate: -> 2

  generateParticle: ->
    src = FW.Math.sample([
        "images/skulls/skull1.png", "images/skulls/skull2.png", "images/skulls/skull3.png",
        "images/skulls/animalskull1.png", "images/skulls/animalskull2.png", "images/skulls/animalskull3.png", "images/skulls/animalskull4.png"
        ])
    new createjs.Bitmap(src)

  initializeParticle: (particle) ->
    bitmapWidth = 64
    bitmapHeight = bitmapWidth

    particle.alpha = 1
    particle.regX = bitmapWidth / 2
    particle.regY = bitmapHeight / 2
    particle.x = 0
    particle.y = 0

    intensity = FW.Math.random(0.5, 1)
    body = @fixture.GetBody()

    velocity = body.GetLinearVelocity()
    vec = Math.tan(velocity.y, velocity.x) + Math.PI + FW.Math.random(-Math.PI / 2, Math.PI / 2)

    particle.xVel = Math.cos(vec) * intensity / bitmapWidth
    particle.yVel = Math.sin(vec) * intensity / bitmapHeight
    particle.rotationVel = FW.Math.random(-5, 5)
    particle.rotation = FW.Math.random(360)
    particle.scaleX = FW.Math.random(0.1, 0.3) / bitmapWidth
    particle.scaleY = particle.scaleX

  updateParticle: (particle) ->
    particle.alpha *= 0.92
    particle.scaleX *= 0.99
    particle.scaleY = particle.scaleX
    particle.x += particle.xVel
    particle.y += particle.yVel
    particle.rotation += particle.rotationVel

  isParticleCullable: (particle) ->
    particle.alpha <= 0.02

  setThrustReticleAngle: (angle) ->
    @thrustReticle.rotation = angle * FW.Math.RAD_TO_DEG

  setGoalAngle: (angle) ->
    @goalReticle.rotation = angle * FW.Math.RAD_TO_DEG

  onTick: ->
    super()
