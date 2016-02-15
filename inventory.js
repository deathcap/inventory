'use strict';

const deepEqual = require('deep-equal');
const ItemPile = require('itempile');
const EventEmitter = require('events').EventEmitter;

class Inventory extends EventEmitter {
  constructor(xSize, ySize, opts) {
    super();
    if (xSize === undefined) xSize = 10;
    if (ySize === undefined) ySize = 1;

    if (xSize <= 0) throw new Error(`inventory invalid xSize: ${xSize}`);
    if (ySize <= 0) throw new Error(`inventory invalid xSize: ${ySize}`);
    const size = xSize * ySize
    this.array = new Array(size);
    this.width = xSize;
    this.height = ySize;
  }

  changed() {
    this.emit('changed');
  }

  give(itemPile) {
    let excess = itemPile.count;

    // first add to existing piles
    for (let i = 0; i < this.array.length; ++i) {
      if (this.array[i] !== undefined && this.array[i].canPileWith(itemPile)) {
        excess = this.array[i].mergePile(itemPile);
      }
      if (itemPile.count === 0) break;
    }

    // then if we have to, add to empty slots
    for (let i = 0; i < this.array.length; ++i) {
      if (this.array[i] === undefined) {
        // start with an 'empty pile' to merge into TODO: improve this hack
        this.array[i] = itemPile.clone();
        this.array[i].count = 0;

        excess = this.array[i].mergePile(itemPile);
        if (this.array[i].count === 0) this.array[i] = undefined;
      }
      if (itemPile.count == 0) break;
    }

    this.changed();

    // what didn't fit
    return excess;
  }

  take(itemPile) {
    for (let i = 0; i < this.array.length; ++i) {
      if (this.array[i] !== undefined && this.array[i].matchesTypeAndTags(itemPile)) {
        const n = Math.min(itemPile.count, this.array[i].count);

        itemPile.count -= n;
        const given = this.takeAt(i, n); // TODO: return?
      }
    }
    return this.changed();
  }

  takeAt(position, count) {
    if (!this.array[position]) return false;
    const ret = this.array[position].splitPile(count);
    if (this.array[position].count === 0) {
      this.array[position] = undefined;
    }
    this.changed();
    return ret;
  }

  toString() {
    const a = [];
    for (let itemPile of this.array) {
      if (itemPile === undefined) {
        a.push('')
      } else {
        a.push(`${itemPile}`);
      }
    }
    return a.join('\t');
  }

  static fromString(s) {
    const strings = s.split('\t'); // literal tab not in JSON.stringify
    const items = [];
    for (let itemString of strings) {
      items.push(ItemPile.fromString(itemString));
    }
    const ret = new Inventory(items.length);
    ret.array = items;
    return ret;
  }

  size() {
    return this.array.length;
  }

  get(i) {
    return this.array[i];
  }

  set(i, itemPile) {
    this.array[i] = itemPile
    return this.changed();
  }

  clear() {
    for (let i = 0; i < this.size(); ++i) {
      this.set(i, undefined);
    }
  }

  transferTo(dest) {
    for (let i = 0; i < this.size(); ++i) {
      dest.set(i, this.get(i));
      this.set(i, undefined);
    }
  }
}

module.exports = Inventory;
