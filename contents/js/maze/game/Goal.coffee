class @Goal extends FW.ParticleGenerator
  maxParticles: 500

  numberOfParticlesToGenerate: -> FW.Math.rand(5, 10)

  generateParticle: ->
    shape = new createjs.Shape()
    shape.graphics.beginFill("#000").drawRect(-0.5, -0.5, 1, 1).endFill()
    shape

  initializeParticle: (particle) ->
    particle.alpha = 1

    vec = FW.Math.random(0, FW.Math.TWO_PI)
    intensity = FW.Math.random(0.5, 1)
    particle.x = Math.cos(vec) * intensity
    particle.y = Math.sin(vec) * intensity
    particle.rotationVel = FW.Math.random(-5, 5)
    particle.rotation = FW.Math.random(360)
    particle.scaleX = FW.Math.random(0.1, 0.3)
    particle.scaleY = particle.scaleX

  updateParticle: (particle) ->
    particle.alpha *= 0.92
    particle.scaleX *= 0.99
    particle.scaleY = particle.scaleX
    particle.x += -particle.x / 10
    particle.y += -particle.y / 10
    particle.rotation += particle.rotationVel

  isParticleCullable: (particle) ->
    particle.alpha <= 0.02

  # Collision name
  name: "Goal"
