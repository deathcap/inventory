'use strict';

const test = require('tape');
const Inventory = require('./');
const ItemPile = require('itempile');

const tabsToCommas = (s) => {
  return s.replace(/\t/g, ',');
};

test('size', (t) => {
  const a = new Inventory();
  t.equal(a.size(), 10);
  t.equal(a.width, 10);
  t.equal(a.height, 1);

  const b = new Inventory(5);
  t.equal(b.size(), 5);
  t.equal(b.width, 5);
  t.equal(b.height, 1);

  const c = new Inventory(3, 2);
  t.equal(c.size(), 3 * 2);
  t.equal(c.width, 3);
  t.equal(c.height, 2);

  t.throws(() => new Inventory(1, 0));
  t.throws(() => new Inventory(0, 1));
  t.throws(() => new Inventory(0, 0));
  t.throws(() => new Inventory(1, -1));
  t.throws(() => new Inventory(-1, 1));
  t.throws(() => new Inventory(-1, -1));

  t.end();
});

test('give', (t) => {
  const inv = new Inventory();

  const expectedInvs = [
    '42:dirt,,,,,,,,,',
    '64:dirt,20:dirt,,,,,,,,',
    '64:dirt,62:dirt,,,,,,,,',
    '64:dirt,64:dirt,40:dirt,,,,,,,',
    '64:dirt,64:dirt,64:dirt,18:dirt,,,,,,',
    '64:dirt,64:dirt,64:dirt,60:dirt,,,,,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,38:dirt,,,,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,16:dirt,,,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,58:dirt,,,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,36:dirt,,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,14:dirt,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,56:dirt,,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,34:dirt,',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,12:dirt',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,54:dirt',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt',
    '64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt,64:dirt'];  // all filled up!

  for (let i = 0; i < 16; ++i) {
    //console.log "\n\n1. #{i}"
    const excess = inv.give(new ItemPile('dirt', 42));
    //console.log 'excess',excess
    //console.log inv+''
    t.equal(tabsToCommas(inv+''), expectedInvs[i]);

    if (i === 15) {
      t.equal(excess, 32);    // partially added
    }
    if (i === 16) {
      t.equal(excess, 42);    // couldn't fit anything
    }
  }

  t.end();
});

test('give large', (t) => {
  const inv = new Inventory();

  inv.give(new ItemPile('dirt', 200));
  console.log(inv+'');

  t.equal(tabsToCommas(inv+''), '64:dirt,64:dirt,64:dirt,8:dirt,,,,,,');
  t.end();
});

test('give fill partial', (t) => {
  const inv = new Inventory();

  inv.array[1] = new ItemPile('dirt', 9);
  t.equal(tabsToCommas(inv+''), ',9:dirt,,,,,,,,');

  inv.give(new ItemPile('dirt', 1));
  t.equal(tabsToCommas(inv+''), ',10:dirt,,,,,,,,');
  t.end();
});

test('give infinite', (t) => {
  const inv = new Inventory();

  inv.give(new ItemPile('love', Infinity));
  t.equal(tabsToCommas(inv+''), 'Infinity:love,,,,,,,,,');
  t.end();
});

test('take', (t) => {
  const inv = new Inventory();

  inv.give(new ItemPile('dirt', 200));
  inv.take(new ItemPile('dirt', 1));
  t.equal(tabsToCommas(inv+''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,');

  inv.take(new ItemPile('dirt', 100));
  console.log(inv+'');
  t.equal(tabsToCommas(inv+''), ',27:dirt,64:dirt,8:dirt,,,,,,');

  t.end();
});

test('clear', (t) => {
  const inv = new Inventory();

  inv.give(new ItemPile('dirt', 200));
  inv.take(new ItemPile('dirt', 1));
  t.equal(tabsToCommas(inv+''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,');

  inv.clear();

  t.equal(tabsToCommas(inv+''), ',,,,,,,,,');

  t.end();
});

test('transferTo', (t) => {
  const inv = new Inventory();
  inv.give(new ItemPile('dirt', 200));
  inv.take(new ItemPile('dirt', 1));
  t.equal(tabsToCommas(inv+''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,');

  const inv2 = new Inventory();
  inv.transferTo(inv2);

  t.equal(tabsToCommas(inv+''), ',,,,,,,,,');
  t.equal(tabsToCommas(inv2+''), '63:dirt,64:dirt,64:dirt,8:dirt,,,,,,');

  inv.give(new ItemPile('diamond', 1));
  inv2.give(new ItemPile('gold', 1));

  t.equal(tabsToCommas(inv+''), '1:diamond,,,,,,,,,');
  t.equal(tabsToCommas(inv2+''), '63:dirt,64:dirt,64:dirt,8:dirt,1:gold,,,,,');


  t.end();
});

test('fromString', (t) => {
  const inv = Inventory.fromString('\t10:dirt\t20:grass');
  console.log(inv+'');
  t.equals(inv.size(), 3);
  t.equals(inv.get(0), undefined);
  t.equals(inv.get(1)+'', '10:dirt');
  t.equals(inv.get(2)+'', '20:grass');
  t.end();
});

