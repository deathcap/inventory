# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

deepEqual = require 'deep-equal'

class Inventory
  constructor: (size, opts) ->
    size = size ? 10
    @array = new Array(size)

  give: (itemPile) ->
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

    # what didn't fit
    return excess

  take: (itemPile) ->
    for i in [0...@array.length]
      if @array[i]? and @array[i].matchesTypeAndTags(itemPile)
        n = Math.min(itemPile.count, @array[i].count)

        itemPile.count -= n
        given = @array[i].splitPile(n)
        if @array[i].count == 0
          @array[i] = undefined


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
    @array[i]

class ItemPile

  constructor: (item, count, tags) ->
    @item = if typeof(item) == 'string' then ItemPile.itemFromString(item) else item
    @count = count ? 1
    @tags = tags ? {}

  # maximum size items should pile to
  @maxPileSize = 64

  # convert item<->string; change these to use non-string items
  @itemFromString: (s) ->
    if s instanceof ItemPile then return s
    if !s then '' else s

  @itemToString: (item) ->
    ''+item

  hasTags: () ->
    Object.keys(@tags).length != 0    # not "{}"

  matchesType: (itemPile) ->
    @item == itemPile.item

  matchesTypeAndCount: (itemPile) ->
    @item == itemPile.item && @count == itemPile.count

  matchesTypeAndTags: (itemPile) ->
    @item == itemPile.item && deepEqual(@tags, itemPile.tags, {strict:true})

  matchesAll: (itemPile) ->
    @matchesTypeAndCount(itemPile) && deepEqual(@tags, itemPile.tags, {strict:true})

  # can this pile be merged with another?
  canPileWith: (itemPile) ->
    return false if itemPile.item != @item
    return false if itemPile.hasTags() or @hasTags() # any tag data makes unpileable
    true

  # combine two piles if possible, altering both this and argument pile
  # returns count of items that didn't fit
  mergePile: (itemPile) ->
    return false if not @canPileWith(itemPile)
    itemPile.count = @increase(itemPile.count)

  # increase count by argument, returning number of items that didn't fit
  increase: (n) ->
    [newCount, excessCount] = @tryAdding(n)
    @count = newCount
    return excessCount

  # decrease count by argument, returning number of items removed
  decrease: (n) ->
    [removedCount, remainingCount] = @trySubtracting(n)
    @count = remainingCount
    return removedCount

  # try combining count of items up to max pile size, returns [newCount, excessCount]
  tryAdding: (n) ->
    sum = @count + n
    if sum > ItemPile.maxPileSize
      return [ItemPile.maxPileSize, sum - ItemPile.maxPileSize] # overflowing pile
    else
      return [sum, 0] # added everything they wanted

  # try removing count of items, returns [removedCount, remainingCount]
  trySubtracting: (n) ->
    difference = @count - n
    if difference < 0
      return [@count, n - @count] # didn't have enough
    else
      return [n, @count - n]  # had enough, some remain

  # remove count of argument items, returning new pile of those items which were split off
  splitPile: (n) ->
    return false if n > @count
    @count -= n

    return new ItemPile(@item, n, @tags)

  toString: () ->
    if @hasTags()
      "#{@count}:#{@item} #{JSON.stringify @tags}"
    else
      "#{@count}:#{@item}"

  @fromString: (s) ->
    a = s.match(/^([^:]+):([^ ]+) ?(.*)/) # assumptions: positive integral count, item name no spaces
    return undefined if not a
    [_, countStr, itemStr, tagsStr] = a
    count = parseInt(countStr, 10)
    item = ItemPile.itemFromString(itemStr)
    if tagsStr && tagsStr.length
      tags = JSON.parse(tagsStr)
    else
      tags = {}

    return new ItemPile(item, count, tags)


module.exports.Inventory = Inventory
module.exports.ItemPile = ItemPile
