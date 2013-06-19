class @ImpactParticleGenerator extends FW.ParticleGenerator
  constructor: ->
    super()
    @_numberOfParticlesToGenerate = 0

  maxParticles: 400

  numberOfParticlesToGenerate: ->
    result = @_numberOfParticlesToGenerate
    @_numberOfParticlesToGenerate = 0
    result

  generateParticle: ->
    shape = new createjs.Shape()
    shape

  initializeParticle: (particle) ->
    [ x, y ] = @_lastImpactLocation

    # graphics.drawRect(-1, -1, 2, 2)
    thetas = [ FW.Math.rand(FW.Math.TWO_PI), FW.Math.rand(FW.Math.TWO_PI), FW.Math.rand(FW.Math.TWO_PI) ].sort()
    coords = for theta in thetas
      [ Math.cos(theta), Math.sin(theta) ]

    # Random triangle
    graphics = particle.graphics
    graphics.beginFill("rgba(179, 35, 255, 1)")
    graphics.beginStroke("rgba(0, 0, 0, 0)")
    graphics.moveTo(coords[0][0], coords[0][1])
    graphics.lineTo(coords[1][0], coords[1][1])
    graphics.lineTo(coords[2][0], coords[2][1])
    graphics.closePath()
    graphics.endFill()

    particle.scaleX = 0
    particle.scaleY = 0
    particle.x = x
    particle.y = y
    particle.rotation = FW.Math.rand(0, 360)

  updateParticle: (particle) ->
    particle.alpha -= 0.01
    particle.scaleX += 0.01
    particle.scaleY = particle.scaleX

  isParticleCullable: (particle) ->
    particle.scaleX > 1

  queueParticle: (x, y) ->
    @_lastImpactLocation = [ x, y ]
    @_numberOfParticlesToGenerate += 4