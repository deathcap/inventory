# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

deepEqual = require 'deep-equal'

class Inventory
  constructor: (opts) ->
    opts = opts ? {}
    size = opts.size ? 10
    @array = new Array(size)

  give: (itemStack) ->
    # first add to existing stacks
    for i in [0...@array.length]
      if @array[i]? and @array[i].canStackWith(itemStack)
        excess = @array[i].mergeStack(itemStack)
      break if itemStack.count == 0

    # then if we have to, add to empty slots
    for i in [0...@array.length]
      if not @array[i]?
        @array[i] = new ItemStack(itemStack.item, 0)
        excess = @array[i].mergeStack(itemStack)
      break if itemStack.count == 0

    # what didn't fit
    return excess

  take: (itemStack) ->
    for i in [0...@array.length]
      if @array[i]? and @array[i].matchesAll(itemStack)
        given = @array[i].splitStack(itemStack.count)


  toString: () ->
    a = []
    for itemStack, i in @array
      if not itemStack?
        a.push('')
      else
        a.push("#{itemStack}")
    a.join(',')

class ItemStack
  constructor: (item, count, tags) ->
    @item = item
    @count = count ? 1
    @tags = tags ? {}

    @maxStackSize = 64

  hasTags: () ->
    Object.keys(@tags).length != 0    # not "{}"

  matchesType: (itemStack) ->
    @item == itemStack.item

  matchesTypeAndCount: (itemStack) ->
    @item == itemStack.item && @count == itemStack.count

  matchesTypeAndTags: (itemStack) ->
    @item == itemStack.item && deepEqual(@tags, itemStack.tags, {strict:true})

  matchesAll: (itemStack) ->
    @matchesTypeAndCount(itemStack) && deepEqual(@tags, itemStack.tags, {strict:true})

  # can this stack be merged with another?
  canStackWith: (itemStack) ->
    return false if itemStack.item != @item
    return false if itemStack.hasTags() or @hasTags() # any tag data makes unstackable
    true

  # combine two stacks if possible, alterning both this and argument stack
  # returns count of items that didn't fit
  mergeStack: (itemStack) ->
    return false if not @canStackWith(itemStack)
    itemStack.count = @increase(itemStack.count)

  # increase count by argument, returning number of items that didn't fit
  increase: (n) ->
    [newCount, excessCount] = @tryAdding(n)
    @count = newCount
    return excessCount

  # try combining count of items up to max stack size, returns [newCount, excessCount]
  tryAdding: (n) ->
    sum = @count + n
    if sum > @maxStackSize
      return [@maxStackSize, sum - @maxStackSize]
    else
      return [sum, 0]

  splitStack: (n) ->
    return false if n > @count
    @count -= n

    return new ItemStack(@item, n, @tags)

  toString: () ->
    if @hasTags()
      "#{@count}:#{@item} #{JSON.stringify @tags}"
    else
      "#{@count}:#{@item}"

class Item
  constructor: (opts) ->
    for k, v of opts
      this[k] = v



module.exports.Inventory = Inventory
module.exports.ItemStack = ItemStack
module.exports.Item = Item


