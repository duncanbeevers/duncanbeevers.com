class @SceneManager
  constructor: (stage) ->
    @_stage = stage
    @_scenes = {}

  # Add the named scene to the dictionary of scenes
  addScene: (sceneName, scene) ->
    @_scenes[sceneName] = scene

  # Stop the current scene,
  # replace it with the named scene
  gotoScene: (sceneName) ->
    stage = @_stage
    currentScene = @_currentScene
    newScene     = @_scenes[sceneName]

    @_currentScene = newScene
    @_currentSceneName = sceneName

    # TODO: Add scene transitions

    stage.removeChild(currentScene)
    currentScene?.onLeaveScene?()

    stage.addChild(newScene)
    newScene.onEnterScene?()

  pushScene: (sceneName) ->
    sceneStack = @_sceneStack ||= []
    sceneStack.push(@_currentSceneName)
    @gotoScene(sceneName)

  popScene: ->
    sceneStack = @_sceneStack
    restoreSceneName = sceneStack.pop()
    @gotoScene(restoreSceneName)
