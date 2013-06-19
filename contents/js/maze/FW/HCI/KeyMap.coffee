FW = @FW ||= {}
HCI = FW.HCI ||= {}



KeyMap =
  SHIFT:   16
  ENTER:   13
  ESCAPE:  27
  SPACE:   32
  COMMAND: 91

  LEFT:  37
  UP:    38
  RIGHT: 39
  DOWN:  40

  DELETE: 8

  keyCodeToChar: (keyCode) ->
    console.log "keyCode: %o", keyCode
    char = String.fromCharCode(keyCode)

    if keyCode == 32
      # Space
      char
    else if keyCode >= 47 && keyCode <= 57
      # 0-9
      char
    else if keyCode >= 65 && keyCode <= 90
      # A-Z
      char
    else
      # Unknown
      false

HCI.KeyMap = KeyMap

# var a = [], s, include = false;

# for (i = 0; i < 255; i++) {
#   s = String.fromCharCode(i);
#   if ((i >= 32 && i <= 126)) { include = true; }
#   if (include) { a.push(s); }
#   else { a.push(undefined); }
# }
# a
isPrintableKeyCode = (keyCode) ->
