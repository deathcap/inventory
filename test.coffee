# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
Inventory = require './'
ItemPile = require 'itempile'

tabsToCommas = (s) ->
  s.replace(/\t/g, ',')

test 'give', (t) ->
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
    excess = inv.give new ItemPile('dirt', 42)
    #console.log 'excess',excess
    #console.log inv+''
    t.equal tabsToCommas(inv+''), expectedInvs[i]

    if i == 15
      t.equal excess, 32    # partially added
    if i == 16
      t.equal excess, 42    # couldn't fit anything

  t.end()

test 'give large', (t) ->
  inv = new Inventory()

  inv.give new ItemPile('dirt', 200)
  console.log(inv+'')

  t.equal tabsToCommas(inv+''), '64:dirt,64:dirt,64:dirt,8:dirt,,,,,,'
  t.end()

test 'take', (t) ->
  inv = new Inventory()

  inv.give new ItemPile('dirt', 200)
  inv.take new ItemPile('dirt', 1)
  t.equal tabsToCommas(inv+''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,'

  inv.take new ItemPile('dirt', 100)
  console.log(inv+'')
  t.equal tabsToCommas(inv+''), ',27:dirt,64:dirt,8:dirt,,,,,,'

  t.end()

test 'fromString', (t) ->
  inv = Inventory.fromString('\t10:dirt\t20:grass')
  console.log(inv+'')
  t.equals(inv.size(), 3)
  t.equals(inv.slot(0), undefined)
  t.equals(inv.slot(1)+'', '10:dirt')
  t.equals(inv.slot(2)+'', '20:grass')
  t.end()

test 'swap', (t) ->
  inv = Inventory.fromString('\t10:dirt\t20:grass')
  inv.swap(1, 2)
  t.equals(inv.toString(), '\t20:grass\t10:dirt')
  t.end()
