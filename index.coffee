# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class Inventory
  constructor: (opts) ->
    opts = opts ? {}
    size = opts.size ? 10
    @array = new Array(size)

  give: (itemStack) ->
    # first add to existing stacks
    for i in @array
      if @array[i]? and @array[i].canStackWith(itemStack)
        excess = @array[i].mergeStack(itemStack)

    # then if we have to, add to empty slots
    for i in @array
      if not @array[i]?
        @array[i] = new ItemStack(itemStack.item, 0)
        excess = @array[i].mergeStack(itemStack)

    # what didn't fit
    return excess

class ItemStack
  constructor: (item, count, tags) ->
    @item = item
    @count = count ? 1
    @tags = tags ? {}

    @tags = undefined if Object.keys(@tags).length == 0

    @maxStackSize = 64

  # can this stack be merged with another?
  canStackWith: (itemStack) ->
    return false if itemStack.item != @item
    return false if itemStack.tags? or @tags # any tag data makes unstackable
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
    "#{@item} x #{@count} #{@tags}"

class Item
  constructor: (opts) ->
    for k, v of opts
      this[k] = v



module.exports.Inventory = Inventory
module.exports.ItemStack = ItemStack
module.exports.Item = Item


