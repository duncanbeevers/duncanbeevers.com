createjs = require("../../lib/easeljs-0.6.1.min.js")
Container = createjs.Container

FW_ProxyProperties = require("./ProxyProperties.coffee").ProxyProperties
FW_ProxyMethods = require("./ProxyMethods.coffee").ProxyMethods

class @ContainerProxy
  constructor: () ->
    container = new Container()
    @_container = container
    instance = @

    parent = undefined
    Object.defineProperty @, 'parent',
      get: -> parent
      set: (value) ->
        if parent
          parent.removeChild(container)
        parent = value
        if parent
          parent.addChild(container)

    FW_ProxyProperties(instance, container, [ 'x', 'y', 'alpha', 'rotation', 'regX', 'regY', 'scaleX', 'scaleY', 'visible' ])
    FW_ProxyMethods(instance, container, [ 'getStage', 'isVisible', 'addChild', 'removeChild', 'addEventListener', 'dispatchEvent', 'globalToLocal' ])

  # Custom overrides for a handful of methods
  updateContext: ->

  draw: ->

  # Emulating a protected method, sorta dangerous
  _tick: ->
    @onTick?()

  onTick: ->

