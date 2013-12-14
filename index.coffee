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

    @maxStackSize = 64

  canStackWith: (itemStack) ->
    return false if itemStack.item != @item
    return false if itemStack.tags? or @tags # any tag data makes unstackable
    true

  mergeStack: (itemStack) ->
    return false if not @canStackWith(itemStack)

    [newCount, excessCount] = @tryAdding(itemStack.count)
    @count = newCount
    @itemStack.count = excessCount
    return excessCount

  tryAdding: (n) ->
    sum = @count + n
    newCount = sum % @maxStackSize
    excessCount = sum - newCount

    return [newCount, excessCount]

  splitStack: (n) ->
    return false if n > @count
    @count -= n

    return new ItemStack(@item, n, @tags)

class Item
  constructor: (opts) ->
    for k, v of opts
      this[k] = v



module.exports.Inventory = Inventory
module.exports.ItemStack = ItemStack
module.exports.Item = Item


