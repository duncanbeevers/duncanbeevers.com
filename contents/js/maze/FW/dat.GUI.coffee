FW = @FW ||= {}

addOne = (instance, receiver, property) ->
  if property.match(/alpha$/i)
    instance.add(receiver, property, 0, 1)
  else if property.match(/color$/i)
    instance.addColor(receiver, property)
  else
    instance.add(receiver, property)

addSettings = (instance, receiver) ->
  for property, value of receiver
    if typeof value == "object"
      addSettings(instance.addFolder(property), value)
    else
      addOne(instance, receiver, property)


gui =
  # add: (receiver, property) ->
  #   addOne(getSingletonInstance(), receiver, property)

  addSettings: (receiver) ->
    gui = new dat.GUI()
    addSettings(gui, receiver)

FW.dat = GUI: gui
