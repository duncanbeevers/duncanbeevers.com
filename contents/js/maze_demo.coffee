Game = require("./maze/game/Game.coffee").Game
game = null
hci = null

tick = (ele, context, width, height, now) ->
  if !game
    game = new Game(ele)

  do game.tick

module.exports = tick
