settings =
  color: "#0FFFFA"

# FW.dat.GUI.addSettings(settings)

class @ProfilePicker extends SliderPicker
  constructor: (profilesArrayData, currentIndex) ->
    # First, we're going to add all of the loaded profiles
    # They're provided in an array, rather than a map
    # This is so the provider can determine in what order they should appear
    #   [ [ profileName, profileData ], ... ]
    sliderElementsToAdd = for [ profileName, profileData ] in profilesArrayData
      sliderElementForProfileData(profileName, profileData)

    # Define the new slider element for adding a new profile
    addNewProfileDisplayObject = createAddNewProfileDisplayObject()
    addNewProfileSliderElement =
      text: "Begin New Game"
      displayObject: addNewProfileDisplayObject

    # Add the add new profile selection to the end of the slider elements
    sliderElementsToAdd.push(addNewProfileSliderElement)

    # Pass all the new slider elements to the constructor for initial population
    super(sliderElementsToAdd, currentIndex)

    # Set instance variables
    @_profilesData = profilesArrayData

  getCurrentProfileData: ->
    @_profilesData[@getCurrentIndex()]

  unshiftNewProfile: (profileName, profileData) ->
    sliderElement = sliderElementForProfileData(profileName, profileData)

    @unshiftElement(sliderElement)

    # Focus on the newly-inserted element
    @_currentIndex = 0
    @_profilesData.unshift([ profileName, profileData])

  selectProfile: (profileName) ->
    index = FW.Util.indexOf @_profilesData, (other) ->
      other[0] == profileName

    @select(index)


sliderElementForProfileData = (profileName, profileData) ->
  text: profileName
  displayObject: createProfileDisplayObject(@, profileData)

createProfileDisplayObject = (profilePicker, profileData) ->
  # Draw the preview image of the maze
  shape = new createjs.Shape()
  graphics = shape.graphics

  graphics.setStrokeStyle(0.001, "round", "bevel")
  graphics.beginStroke("rgba(0, 0, 0, 0)")
  graphics.beginFill(settings.color)
  # Head
  graphics.drawCircle(0, -0.5, 0.25)
  # Shoulders
  graphics.drawCircle(-0.25, 0, 0.25)
  graphics.drawCircle(0.25, 0, 0.25)
  # Fill in torso
  graphics.drawRect(-0.25, -0.25, 0.5, 0.25)
  graphics.drawRect(-0.5, 0, 1, 0.5)

  graphics.endStroke()
  graphics.endFill()

  radius = Math.sqrt(2)

  # Scale it down to fit based on drawing boundaries
  shape.scaleX = 1 / (radius * 2)
  shape.scaleY = shape.scaleX

  shape

createAddNewProfileDisplayObject = ->
  # TODO: Actually trace the plus symbol rather than draw
  # overlapping rectangles
  shape = new createjs.Shape()
  graphics = shape.graphics

  graphics.setStrokeStyle(0.01, "round", "bevel")
  graphics.beginStroke(settings.color)
  graphics.beginFill(settings.color)

  graphics.drawRect(-0.25, -0.5, 0.5, 1)
  graphics.drawRect(-0.5, -0.25, 1, 0.5)

  graphics.endStroke()
  graphics.endFill()

  radius = 1

  # Scale it down to fit based on drawing boundaries
  shape.scaleX = 1 / (radius * 2)
  shape.scaleY = shape.scaleX

  shape

# Export the function to create the profile picture display object
ProfilePicker.createAddNewProfileDisplayObject = createAddNewProfileDisplayObject
