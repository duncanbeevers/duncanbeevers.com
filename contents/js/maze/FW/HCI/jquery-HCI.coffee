window = @
localStorage = window.localStorage
localStorageProfilesKey = "mazeoid:profiles"

# Generate an HCI instance bound to DOM events by jQuery
$.FW_HCI = ->
  hci = new FW.HCI.HCI()

  onVisibilityChange = (event) ->
    documentHidden = document.hidden || document.webkitHidden

    if documentHidden
      hci.windowBecameVisible()
    else
      hci.windowBecameInvisible()

  $document = $(document)
  $document.on "visibilitychange",       onVisibilityChange
  $document.on "webkitvisibilitychange", onVisibilityChange

  $document.on "keydown", (event) ->
    keyCode = event.keyCode

    hci.triggerKeyDown(keyCode)
    if keyCode == FW.HCI.KeyMap.ESCAPE || keyCode == FW.HCI.KeyMap.DELETE
      event.preventDefault()

  $document.on "keyup",   (event) ->
    keyCode = event.keyCode

    hci.triggerKeyUp(event.keyCode)
    if keyCode == FW.HCI.KeyMap.ESCAPE || keyCode == FW.HCI.KeyMap.DELETE
      event.preventDefault()

  $document.on "touchmove", (event) -> event.preventDefault()

  hci.saveProfile = (profileName, profileData) ->
    profilesData = loadProfilesData()
    profilesData[profileName] = profileData
    localStorage.setItem(localStorageProfilesKey, JSON.stringify(profilesData))
    loadProfilesCached = profilesData

  hci.loadProfile = (profileName) ->
    loadProfilesData()[profileName]

  hci.loadProfileNames = ->
    Object.keys(loadProfilesData())

  return hci

loadProfilesCached = false
loadProfilesData = () ->
  if !loadProfilesCached
    try
      loadProfilesCached = JSON.parse(localStorage.getItem(localStorageProfilesKey)) || {}
    catch _
      loadProfilesCached = {}

  loadProfilesCached
