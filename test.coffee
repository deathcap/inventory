# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Inventory, ItemStack, Item} = require './'

test 'ItemStack create default', (t) ->
  a = new ItemStack('dirt')
  t.equal a.item, 'dirt'
  t.equal a.count, 1
  t.deepEqual a.tags, {}
  t.end()

test 'ItemStack empty tags', (t) ->
  a = new ItemStack('dirt', 1, {})
  t.deepEqual a.tags, {}
  t.end()

test 'ItemStack increase', (t) ->
  a = new ItemStack('dirt', 1)
  excess = a.increase(10)
  t.equal a.count, 11
  t.equal excess, 0

  excess = a.increase(100)
  t.equal a.count, 64
  t.equal excess, 47 
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

test 'ItemStack split', (t) ->
  a = new ItemStack('dirt', 64)
  b = a.splitStack(32)

  t.equal(a.count, 32)
  t.equal(b.count, 32)
  t.equal(a.item, b.item)
  t.equal(a.tags, b.tags)
  t.end()

test 'ItemStack split bad', (t) ->
  a = new ItemStack('dirt', 10)
  b = a.splitStack(1000)
  
  t.equal(b, false)
  t.equal(a.count, 10)  # unchanged
  t.end()

test 'ItemStack toString', (t) ->
  a = new ItemStack('dirt', 42)
  console.log a.toString()
  t.equal(a+"", 'dirt x 42 {}')
  t.end()
