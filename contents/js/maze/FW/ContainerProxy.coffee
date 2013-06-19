FW = @FW ||= {}

class FW.ContainerProxy
  constructor: () ->
    container = new createjs.Container()
    @_container = container
    instance = @

    parent = undefined
    Object.defineProperty @, 'parent'
      get: -> parent
      set: (value) ->
        if parent
          parent.removeChild(container)
        parent = value
        if parent
          parent.addChild(container)

    FW.ProxyProperties(instance, container, [ 'x', 'y', 'alpha', 'rotation', 'regX', 'regY', 'scaleX', 'scaleY', 'visible' ])
    FW.ProxyMethods(instance, container, [ 'getStage', 'isVisible', 'addChild', 'removeChild', 'addEventListener', 'dispatchEvent', 'globalToLocal' ])

  # Custom overrides for a handful of methods
  updateContext: ->

  draw: ->

  # Emulating a protected method, sorta dangerous
  _tick: ->
    @onTick?()

  onTick: ->
