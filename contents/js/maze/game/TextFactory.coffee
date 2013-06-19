@TextFactory =
  create: (text, color) ->
    t              = new createjs.Text(text)
    t.font         = "48px MazeoidFont"
    t.textAlign    = "center"
    t.textBaseline = "middle"
    t.color        = color || "#FFFFFF"

    t

  pluralize: (word, count) ->
    if count == 1
      word
    else
      "#{word}s"
