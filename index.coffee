# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class Inventory
  constructor: (opts) ->
    opts = opts ? {}
    size = opts.size ? 10
    @array = new Array(size)

Inventory::give = (itemStack) ->
  for i in @array
    if @array[i]? and @array[i].canStackWith(itemStack)
      excess = @array[i].mergeWith itemStack

class ItemStack
  constructor: (item, count, tags) ->
    @item = item
    @count = count
    @tags = tags

  canStackWith: (itemStack) ->
    return false if itemStack.item != @item
    return false if itemStack.tags? or @tags # any tag data makes unstackable
    true

  # Combine this item stack with another of the same type, returning count that didn't fit (excess)
  mergeWith: (itemStack) ->
    n = @count + itemStack.count
    stackSize = @item.maxStackSize()
    @count = n % stackSize
    n - @count

class Item
  constructor: (opts) ->
    for k, v of opts
      this[k] = v

  maxStackSize: () ->
    return 64



module.exports.Inventory = Inventory
module.exports.ItemStack = ItemStack
module.exports.Item = Item


