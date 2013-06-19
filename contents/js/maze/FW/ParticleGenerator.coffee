FW = @FW ||= {}

class FW.ParticleGenerator extends FW.ContainerProxy
  constructor: () ->
    super()

    @_particles = []
    @_recycledParticles = []

  particleContainer: ->
    if @absolutePlacement
      @parent
    else
      @_container

  recycle: (particle) ->
    @particleContainer().removeChild(particle)
    @_recycledParticles.push(particle)

  onTick: ->
    particles = @_particles

    particlesToKeep = []
    for particle in particles
      @updateParticle(particle)
      if @isParticleCullable(particle)
        @recycle(particle)
      else
        particlesToKeep.push(particle)

    @_particles = particles = particlesToKeep

    # Figure out how many total particles we need to spawn this tick
    numNeeded = Math.max(Math.min(@numberOfParticlesToGenerate(), @maxParticles - particles.length), 0)
    # Bail out if there's nothing more to do
    return unless numNeeded > 0

    # Get any we can from recycling
    recycled = @_recycledParticles
    numToAcquireFromRecycle = Math.min(recycled.length, numNeeded)

    # Generate any we can't acquire from recycling
    numToGenerate = numNeeded - numToAcquireFromRecycle

    # All "new" particles will need to be initialized
    # Start the list with the ones we're acquring from recycling
    # and remove them the recycling list
    particlesToInitialize = recycled.slice(0, numToAcquireFromRecycle)
    @_recycledParticles = recycled.slice(numToAcquireFromRecycle)

    # Generate particles and add them to the init list
    for i in [1..numToGenerate]
      particle = @generateParticle()
      particles.push(particle)
      particlesToInitialize.push(particle)

    container = @particleContainer()

    for particle in particlesToInitialize
      @initializeParticle(particle)
      if @absolutePlacement
        particle.x += @x
        particle.y += @y

      particles.push(particle)
      container.addChild(particle)
