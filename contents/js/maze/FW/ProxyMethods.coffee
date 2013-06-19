FW = @FW ||= {}

ProxyMethods = (proxy, target, methods) ->
  if typeof methods == "string"
    method = methods
    proxy[method] = (args...) ->
      fn = target[method]
      if fn
        fn.apply(target, args)
  else
    for method in methods
      ProxyMethods(proxy, target, method)

FW.ProxyMethods = ProxyMethods
