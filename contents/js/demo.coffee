random = Math.random
floor = Math.floor

# demos = [
#   require("./rdots_demo.coffee"),
#   require("./lumps_demo.coffee")
# ]

demos = [
  require("./maze_demo.coffee")
]

demo = demos[floor(random() * demos.length)]

# Get the moment, controls clock rate
getNow = -> floor(new Date())

# Memoize reference to demo canvas element
getEle = do ->
  ele = null
  ->
    if ele
      return ele
    else
      eles = document.getElementsByClassName("demo")
      ele = eles[0]

# Memoize the 2d context of the demo canvas element
getContext = do ->
  context = null
  (ele) ->
    return unless ele
    context ||= ele.getContext("2d")

# shorthand function refences
requestAnimationFrame = window.requestAnimationFrame
getComputedStyle      = window.getComputedStyle
floor                 = Math.floor

# Note the start time of the script
start = getNow()

onTick = ->
  requestAnimationFrame(onTick)

  now = getNow()

  # Try and get element and 2d context
  ele = getEle()
  context = getContext(ele)

  # Wait until next tick if we couldn't get them
  return unless ele && context

  # Demo resolution equals rendered dimensions
  ele_computed_style = getComputedStyle(ele)
  ele_width = parseInt(ele_computed_style.width, 10)
  ele_height = parseInt(ele_computed_style.height, 10)

  # If the computed size of the element changed,
  # apply the values literally
  if ele.width != ele_width || ele.height != ele_height
    ele.width = ele_width
    ele.height = ele_height

  # Invoke the plugin
  demo(ele, context, ele_width, ele_height, now)

module.exports =
  start: () ->
    # Kick off the first draw
    requestAnimationFrame(onTick)
