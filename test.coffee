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
  g = new ItemStack('magic', 2, {foo:-7})
  t.equal(d.matchesType(d), true)
  t.equal(d.matchesTypeAndCount(e), true)
  t.equal(d.matchesAll(e), false)
  t.equal(d.matchesAll(f), true)
  t.equal(g.matchesTypeAndTags(d), true)

  t.end()

test 'ItemStack toString', (t) ->
  a = new ItemStack('dirt', 42)
  console.log a.toString()
  t.equal(a+'', '42:dirt')

  b = new ItemStack('magic', 1, {foo:-7})
  console.log b.toString()
  t.equal(b+'', '1:magic {"foo":-7}')
  t.end()

test 'ItemStack fromString', (t) ->
  a = ItemStack.fromString('24:dirt')
  console.log(a)
  t.equal(a.count, 24)
  t.equal(a.item, 'dirt')
  t.equal(a.hasTags(), false)
  t.end()

test 'ItemStack fromString/toString roundtrip', (t) ->
  strings = [
    '24:dirt'
    '48:dirt'
    '1000:dirt'
    '0:dirt'
    '1:foo {"tag":1}'
    '2:hmm {"foo":[],"bar":2}'
    ]
  for s in strings
    b = ItemStack.fromString(s)
    outStr = b+''
    t.equal(s, outStr)
    console.log("=",s, outStr)
  t.end()

test 'ItemStack itemFromString', (t) ->
  a = ItemStack.itemFromString('foo')
  t.equals(a, 'foo')

  b = ItemStack.itemFromString(undefined)
  t.equal(b, '')

  c = ItemStack.itemToString('bar')
  t.equals(c, 'bar')

  d = ItemStack.itemToString(ItemStack.itemFromString(null))
  t.equals(d, '')
  t.end()

tabsToCommas = (s) ->
  s.replace(/\t/g, ',')

test 'Inventory give', (t) ->
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
    t.equal tabsToCommas(inv+''), expectedInvs[i]

    if i == 15
      t.equal excess, 32    # partially added
    if i == 16
      t.equal excess, 42    # couldn't fit anything

  t.end()

test 'Inventory give large', (t) ->
  inv = new Inventory()

  inv.give new ItemStack('dirt', 200)
  console.log(inv+'')

  t.equal tabsToCommas(inv+''), '64:dirt,64:dirt,64:dirt,8:dirt,,,,,,'
  t.end()

test 'Inventory take', (t) ->
  inv = new Inventory()

  inv.give new ItemStack('dirt', 200)
  inv.take new ItemStack('dirt', 1)
  t.equal tabsToCommas(inv+''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,'

  inv.take new ItemStack('dirt', 100)
  console.log(inv+'')
  t.equal tabsToCommas(inv+''), ',27:dirt,64:dirt,8:dirt,,,,,,'

  t.end()

test 'Inventory fromString', (t) ->
  inv = Inventory.fromString('\t10:dirt\t20:grass')
  console.log(inv+'')
  t.equals(inv.size(), 3)
  t.equals(inv.slot(0), undefined)
  t.equals(inv.slot(1)+'', '10:dirt')
  t.equals(inv.slot(2)+'', '20:grass')
  t.end()
