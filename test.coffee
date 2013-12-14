# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Inventory, ItemStack, Item} = require './'

test 'ItemStack create default', (t) ->
  a = new ItemStack('dirt')
  t.equal a.item, 'dirt'
  t.equal a.count, 1
  t.equal a.tags, undefined
  t.end()

test 'ItemStack empty tags', (t) ->
  a = new ItemStack('dirt', 1, {})
  t.equal a.tags, undefined  # not {}
  t.end()

test 'ItemStack merge', (t) ->
  a = new ItemStack('dirt', 1)
  b = new ItemStack('dirt', 80)

  excess = a.mergeStack(b)

  t.equal(a.item, b.item)
  t.equal(a.count + b.count, 80 + 1)
  t.equal(excess, b.count)
  t.equal(a.count, 64)
  t.equal(b.count, 17)

  t.end()
