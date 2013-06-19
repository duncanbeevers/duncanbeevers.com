FW = @FW ||= {}

ProxyProperties = (proxy, original, properties) ->
  if typeof properties == "string"
    property = properties
    Object.defineProperty proxy, property,
      get: ->
        original[property]
      set: (value) ->
        original[property] = value
  else
    for property in properties
      ProxyProperties(proxy, original, property)

FW.ProxyProperties = ProxyProperties
