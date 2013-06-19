FW = @FW ||= {}

class FW.NamedContactListener
  constructor: ->
    @_contactListeners = {}

  BeginContact: (contact, impulse) ->
    handleContact('begin', @_contactListeners, contact)
  EndContact: (contact, impulse) ->
    handleContact('end', @_contactListeners, contact)
  PreSolve: (contact, impulse) ->
    handleContact('pre', @_contactListeners, contact, impulse)
  PostSolve: (contact, impulse) ->
    handleContact('post', @_contactListeners, contact, impulse)


  registerContactListener: (nameA, nameB, beginContactListener, endContactListener, preSolveListener, postSolveListener) ->
    keyName = [ nameA, nameB ].join("/")
    @_contactListeners[keyName] ||= []
    @_contactListeners[keyName].push
      begin: beginContactListener
      end:   endContactListener
      pre:   preSolveListener
      post:  postSolveListener

  registerContinuousContactListener: (nameA, nameB, duringContact) ->
    tickerContact = undefined
    tickerFixtureA = undefined
    tickerFixtureB = undefined

    ticker = tick: -> duringContact(tickerContact, tickerFixtureA, tickerFixtureB)

    enableNotifyInContact = (contact, fixtureA, fixtureB) ->
      tickerContact = contact
      tickerFixtureA = fixtureA
      tickerFixtureB = fixtureB
      createjs.Ticker.addListener(ticker)

    disableNotifyInContact = (contact, fixtureA, fixtureB) ->
      createjs.Ticker.removeListener(ticker)

    @registerContactListener(nameA, nameB, enableNotifyInContact, disableNotifyInContact)


handleContact = (key, contactListeners, contact, impulse) ->
  fixtureA = contact.GetFixtureA()
  fixtureB = contact.GetFixtureB()

  userDataA = fixtureA.GetUserData()
  userDataB = fixtureB.GetUserData()

  # If the user data isn't there, we don't do anything with it
  if userDataA && userDataB
    nameA = userDataA.name
    nameB = userDataB.name

    if nameA == nameB
      # If both names are the same, we must only run the listeners once
      namePairs = [ [ nameA, nameB ] ]
    else
      namePairs = [ [ nameA, nameB ], [ nameB, nameA ] ]

    for [pairNameA, pairNameB] in namePairs
      pairName = [ pairNameA, pairNameB ].join("/")

      if contactListeners[pairName]
        for listenerMap in contactListeners[pairName] when listenerMap[key]
          # Callbacks registered expect this library to work out
          # who did what in the collision. Clients expect the
          # entities to be passed into the callback in the order
          # the callback registered
          # Here we normalize the refences
          if pairNameA == nameA
            primary   = fixtureA
            secondary = fixtureB
          else
            primary   = fixtureB
            secondary = fixtureA

          listener = listenerMap[key]
          if impulse
            listener(contact, impulse, primary, secondary)
          else
            listener(contact, primary, secondary)
