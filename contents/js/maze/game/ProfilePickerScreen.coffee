class @ProfilePickerScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    screen = @

    sceneManager = game.getSceneManager()
    titleBox = new TitleBox()
    profileNames = hci.loadProfileNames()
    profilesData = {}
    for profileName in profileNames
      profilesData[profileName] = hci.loadProfile(profileName)

    profilePicker      = setupProfilePicker(screen, profilesData)
    addNewProfileInput = setupAddNewProfileInput(hci, sceneManager, profilePicker)
    sliderOverlay      = setupSliderOverlay(screen, hci, profilePicker)

    screen.addChild(profilePicker)
    screen.addChild(titleBox)
    screen.addChild(sliderOverlay)

    sceneManager.addScene("newProfileInput", addNewProfileInput)

    @_game               = game
    @_hci                = hci
    @_sceneManager       = sceneManager
    @_profilePicker      = profilePicker
    @_addNewProfileInput = addNewProfileInput

  onEnterScene: ->
    screen = @
    profilePicker = @_profilePicker

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}",  -> onPressedEnter(screen) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> onPressedEscape(screen) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",   -> profilePicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}",  -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  setProfileData: (profileName, profileData) ->
    @_game.setProfileData(profileName, profileData)

onPressedEnter = (screen) ->
  profilePicker      = screen._profilePicker
  sceneManager       = screen._sceneManager
  addNewProfileInput = screen._addNewProfileInput

  index  = profilePicker.getCurrentIndex()
  length = profilePicker.getLength()

  if index == length - 1
    # Last item is Add New Profile
    sceneManager.pushScene("newProfileInput")
  else
    # Otherwise we're loading an existing profile
    [ profileName, profileData ] = profilePicker.getCurrentProfileData()
    screen.setProfileData(profileName, profileData)
    sceneManager.pushScene("titleScreen")


onPressedEscape = (screen) ->
  # Something?

setupProfilePicker = (screen, profilesData) ->
  profilesDataByCreatedAt = FW.Util.mapToArraySortedByAttribute(profilesData, 'createdAt', true)
  profilesDataByLastLoadedAt = FW.Util.mapToArraySortedByAttribute(profilesData, 'lastLoadedAt', true)
  mostRecentlyLoaded = profilesDataByLastLoadedAt[0]

  initialIndex = FW.Util.indexOf profilesDataByCreatedAt, (other) ->
    other[0] == mostRecentlyLoaded[0]
  if initialIndex == -1
    initialIndex = 0

  profilePicker = new ProfilePicker(profilesDataByCreatedAt, initialIndex)
  profilePicker.addEventListener "tick", ->
    profilesVisibleOnScreen = 2

    canvas = screen.getStage().canvas
    profilePicker.scaleX = Math.min(canvas.width, canvas.height) / profilesVisibleOnScreen
    profilePicker.scaleY = profilePicker.scaleX

    profilePicker.x = canvas.width / 2
    profilePicker.y = 200

  profilePicker

setupSliderOverlay = (screen, hci, profilePicker) ->
  goPrev = -> profilePicker.selectPrevious()
  goNext = -> profilePicker.selectNext()
  goSelect = -> onPressedEnter(screen)
  overlay = new SliderOverlay(goPrev, goNext, goSelect)
  overlay

setupAddNewProfileInput = (hci, sceneManager, profilePicker) ->
  createNewProfile = (profileName) ->
    extantProfile = hci.loadProfile(profileName)
    if extantProfile
      profileData = extantProfile
      profilePicker.selectProfile(profileName)
    else
      now = FW.Time.now()
      profileData = {
        name         : profileName
        createdAt    : now
        lastLoadedAt : now
      }
      hci.saveProfile(profileName, profileData)
      profilePicker.unshiftNewProfile(profileName, profileData)

    sceneManager.popScene()

    inputOverlay.setValue("")

  cancelAddNewProfile = ->
    sceneManager.popScene()

  inputOverlay = new InputOverlay(hci, "What's your name?", "", createNewProfile, cancelAddNewProfile)

  inputOverlay
