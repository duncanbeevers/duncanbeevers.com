# Merge properties from several objects onto the first
module.exports = (objs...) ->
  # Pull the first object off the list
  onto = objs.shift()

  # For every other object,
  #   add its properties to the first object
  for from in objs
    for key, val of from
      onto[key] = val

  # Return it
  onto
