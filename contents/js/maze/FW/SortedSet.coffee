SortedArray = require("../FW/SortedArray").FW.SortedArray

FW = @FW ||= {}

class FW.SortedSet extends SortedArray
  insert: (element) ->
    i = @indexOf(element)
    if -1 == i
      super(element)
    else
      @collection()[i]

FW.SortedSet.FuzzyNumericalComparator = (threshold) ->
  (a, b) ->
    if (Math.abs(a - b) < threshold)
      0
    else if (a < b) then -1
    else 1
