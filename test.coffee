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

test 'ItemStack matches', (t) ->
  a = new ItemStack('dirt', 3)
  b = new ItemStack('dirt', 4)
  
  t.equal(a.matchesType(b), true)
  t.equal(a.matchesTypeAndCount(b), false)
  t.equal(a.matchesAll(b), false)

  c = new ItemStack('dirt', 4)
  t.equal(b.matchesType(c), true)
  t.equal(b.matchesTypeAndCount(c), true)
  t.equal(b.matchesAll(c), true)

  t.equal(c.matchesType(b), true)
  t.equal(c.matchesTypeAndCount(b), true)
  t.equal(c.matchesAll(b), true)

  d = new ItemStack('magic', 1, {foo:-7})
  e = new ItemStack('magic', 1, {foo:54})
  f = new ItemStack('magic', 1, {foo:-7})
  t.equal(d.matchesType(d), true)
  t.equal(d.matchesTypeAndCount(e), true)
  t.equal(d.matchesAll(e), false)
  t.equal(d.matchesAll(f), true)

  t.end()

test 'ItemStack toString', (t) ->
  a = new ItemStack('dirt', 42)
  console.log a.toString()
  t.equal(a+'', '42:dirt')

  b = new ItemStack('magic', 1, {foo:-7})
  console.log b.toString()
  t.equal(b+'', '1:magic {"foo":-7}')
  t.end()

test 'Inventory', (t) ->
  inv = new Inventory()

  expectedInvs = [
    '42:dirt,,,,,,,,,'
    '64:dirt,20:dirt,,,,,,,,'
    '64:dirt,62:dirt,,,,,,,,'
    '64:dirt,64:dirt,40:dirt,,,,,,,'
    '64:dirt,64:dirt,64:dirt,18:dirt,,,,,,'
    '64:dirt,64:dirt,64:dirt,60:dirt,,,,,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,38:dirt,,,,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,16:dirt,,,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,58:dirt,,,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,36:dirt,,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,14:dirt,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,56:dirt,,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,34:dirt,'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,12:dirt'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,54:dirt'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt'
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt']  # all filled up!


  for i in [0..16]
    #console.log "\n\n1. #{i}"
    excess = inv.give new ItemStack('dirt', 42)
    #console.log 'excess',excess
    #console.log inv+''
    t.equal inv+'', expectedInvs[i]

    if i == 15
      t.equal excess, 32    # partially added
    if i == 16
      t.equal excess, 42    # couldn't fit anything

  t.end()

