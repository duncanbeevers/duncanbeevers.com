FW = @FW ||= {}

find = (collection, element, comparator) ->
  low = 0
  high = collection.length - 1
  i = null
  matched = false
  matched_index = -1
  while low <= high
    i = Math.floor((low + high) / 2)
    comparison = comparator(collection[i], element)
    if comparison < 0
      low = i + 1
    else if comparison > 0
      high = i - 1
    else
      matched = true
      matched_index = i
      break

  {
    matched: matched
    i: matched_index
    high: high
    low: low
  }

class FW.SortedArray
  constructor: (comparator) ->
    @_comparator = comparator
    @_collection = []

  insert: (element) ->
    collection = @_collection
    low = find(collection, element, @_comparator).low
    collection.splice(low, 0, element)
    element

  indexOf: (element) ->
    find(@_collection, element, @_comparator).i

  find: (element) ->
    i = @indexOf(element)
    if -1 != i
      @_collection[i]

  collection: ->
    @_collection

FW.SortedArray.OrdinalComparator = (a, b) ->
  if (a < b) then -1
  else if (a == b) then 0
  else 1