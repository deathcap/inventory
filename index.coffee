# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

deepEqual = require 'deep-equal'
ItemPile = require 'itempile'
EventEmitter = (require 'events').EventEmitter

module.exports =
class Inventory extends EventEmitter
  constructor: (size, opts) ->
    size = size ? 10
    @array = new Array(size)

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
        @array[i] = new ItemPile(itemPile.item, 0)
        excess = @array[i].mergePile(itemPile)
      break if itemPile.count == 0

    @changed()

    # what didn't fit
    return excess

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

  slot: (i) ->
    @array[i]   # TODO: emit events when changed directly?

