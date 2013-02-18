Array::indexOf or= (item) ->
  for x, i in this
    return i if x is item
  return -1
