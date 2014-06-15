
deepEqual = require 'deep-equal'
ItemPile = require 'itempile'
EventEmitter = (require 'events').EventEmitter

module.exports =
class Inventory extends EventEmitter
  constructor: (xSize=10, ySize=1, opts) ->
    throw new Error("inventory invalid xSize: #{xSize}") if xSize <= 0
    throw new Error("inventory invalid xSize: #{ySize}") if ySize <= 0
    size = xSize * ySize
    @array = new Array(size)
    @width = xSize
    @height = ySize

  changed: () ->
    @emit 'changed'

  give: (itemPile) ->
    excess = itemPile.count

    # first add to existing piles
    for i in [0...@array.length]
      if @array[i]? and @array[i].canPileWith(itemPile)
        excess = @array[i].mergePile(itemPile)
      break if itemPile.count == 0

    # then if we have to, add to empty slots
    for i in [0...@array.length]
      if not @array[i]?
        # start with an 'empty pile' to merge into TODO: improve this hack
        @array[i] = itemPile.clone()
        @array[i].count = 0

        excess = @array[i].mergePile(itemPile)
        @array[i] = undefined if @array[i].count == 0
      break if itemPile.count == 0

    @changed()

    # what didn't fit
    return excess

  take: (itemPile) ->
    for i in [0...@array.length]
      if @array[i]? and @array[i].matchesTypeAndTags(itemPile)
        n = Math.min(itemPile.count, @array[i].count)

        itemPile.count -= n
        given = @takeAt i, n
    @changed()

  takeAt: (position, count) ->
    return false if not @array[position]
    ret = @array[position].splitPile count
    if @array[position].count == 0
      @array[position] = undefined
    @changed()
    ret


  toString: () ->
    a = []
    for itemPile, i in @array
      if not itemPile?
        a.push('')
      else
        a.push("#{itemPile}")
    a.join('\t')

  @fromString: (s) ->
    strings = s.split('\t') # literal tab not in JSON.stringify
    items = (ItemPile.fromString(s) for s in strings)
    ret = new Inventory(items.length)
    ret.array = items
    ret

  size: () ->
    @array.length

  get: (i) ->
    @array[i]

  set: (i, itemPile) ->
    @array[i] = itemPile
    @changed()

  clear: () ->
    for i in [0...@size()]
      @set i, undefined

  transferTo: (dest) ->
    for i in [0...@size()]
      dest.set i, @get(i)
      @set i, undefined

