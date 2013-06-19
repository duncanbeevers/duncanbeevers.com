class @Lamp extends FW.ParticleGenerator
  maxParticles: 30
  numberOfParticlesToGenerate: -> FW.Math.rand(7) == 0

  generateParticle: ->
    new createjs.Shape()

  initializeParticle: (particle) ->
    particle.alpha = 1
    particle.rotationVel = FW.Math.random(-5, 5)

    graphics = particle.graphics
    graphics.clear()

    graphics.beginFill("rgba(172, 255, 85, 0.1)")
    graphics.drawCircle(FW.Math.random(-0.1, 0.1), FW.Math.random(-0.1, 0.1), 1)
    graphics.endFill()

  updateParticle: (particle) ->
    particle.alpha *= 0.92
    # particle.scaleX *= 0.99
    # particle.scaleY = particle.scaleX
    # particle.x += particle.xVel
    # particle.y += particle.yVel
    particle.rotation += particle.rotationVel

  isParticleCullable: (particle) ->
    particle.alpha <= 0.02

  onTick: ->
    super()
    body = @fixture.GetBody()
    position = body.GetPosition()
    @x = position.x
    @y = position.y
