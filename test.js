// Generated by CoffeeScript 1.6.3
(function() {
  var Inventory, ItemPile, tabsToCommas, test;

  test = require('tape');

  Inventory = require('./');

  ItemPile = require('itempile');

  tabsToCommas = function(s) {
    return s.replace(/\t/g, ',');
  };

  test('give', function(t) {
    var excess, expectedInvs, i, inv, _i;
    inv = new Inventory();
    expectedInvs = ['42:dirt,,,,,,,,,', '64:dirt,20:dirt,,,,,,,,', '64:dirt,62:dirt,,,,,,,,', '64:dirt,64:dirt,40:dirt,,,,,,,', '64:dirt,64:dirt,64:dirt,18:dirt,,,,,,', '64:dirt,64:dirt,64:dirt,60:dirt,,,,,,', '64:dirt,64:dirt,64:dirt,64:dirt,38:dirt,,,,,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,16:dirt,,,,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,58:dirt,,,,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,36:dirt,,,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,14:dirt,,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,56:dirt,,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,34:dirt,', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,12:dirt', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,54:dirt', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt', '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt'];
    for (i = _i = 0; _i <= 16; i = ++_i) {
      excess = inv.give(new ItemPile('dirt', 42));
      t.equal(tabsToCommas(inv + ''), expectedInvs[i]);
      if (i === 15) {
        t.equal(excess, 32);
      }
      if (i === 16) {
        t.equal(excess, 42);
      }
    }
    return t.end();
  });

  test('give large', function(t) {
    var inv;
    inv = new Inventory();
    inv.give(new ItemPile('dirt', 200));
    console.log(inv + '');
    t.equal(tabsToCommas(inv + ''), '64:dirt,64:dirt,64:dirt,8:dirt,,,,,,');
    return t.end();
  });

  test('take', function(t) {
    var inv;
    inv = new Inventory();
    inv.give(new ItemPile('dirt', 200));
    inv.take(new ItemPile('dirt', 1));
    t.equal(tabsToCommas(inv + ''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,');
    inv.take(new ItemPile('dirt', 100));
    console.log(inv + '');
    t.equal(tabsToCommas(inv + ''), ',27:dirt,64:dirt,8:dirt,,,,,,');
    return t.end();
  });

  test('fromString', function(t) {
    var inv;
    inv = Inventory.fromString('\t10:dirt\t20:grass');
    console.log(inv + '');
    t.equals(inv.size(), 3);
    t.equals(inv.slot(0), void 0);
    t.equals(inv.slot(1) + '', '10:dirt');
    t.equals(inv.slot(2) + '', '20:grass');
    return t.end();
  });

  test('swap', function(t) {
    var inv;
    inv = Inventory.fromString('\t10:dirt\t20:grass');
    inv.swap(1, 2);
    t.equals(inv.toString(), '\t20:grass\t10:dirt');
    return t.end();
  });

}).call(this);
