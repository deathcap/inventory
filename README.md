# inventory

Simple finite stackable item inventories (for games).

[![Build Status](https://travis-ci.org/deathcap/inventory.png)](https://travis-ci.org/deathcap/inventory)

Requires a ES6-compatible environment (tested on Node v4.2.4)

## Creation

A new inventory can be created given its desired size (number of slots):

    var Inventory = require('inventory');
    var inv = new Inventory(5);

If omitted, defaults to 10. You can pass two arguments for 2D inventory:

    new Inventory(3, 2)

creates a 3x2 = 6 slot inventory (3 columns, 2 rows). Internally it still
stored as one-dimensional, but other modules can query the dimensions
(width and height).

## Adding items

Items are added to an inventory using `give`, passing an [itempile](https://github.com/deathcap/itempile) instance:

    inv.give(new ItemPile('dirt', 42));

will add 42 dirt to `inv`, returning the quantity that could not be added if the inventory is full.
`give` first searches for existing piles and attempts to merge if possible, otherwise it will occupy an
empty slot. 

This merging algorithm can be demonstrated by repeatingly giving 42 dirt and calling `toString` to see the contents:

    42:dirt
    64:dirt	20:dirt
    64:dirt	62:dirt
    64:dirt	64:dirt	40:dirt
    etc.

The items pile up to `ItemPile.maxPileSize`, default 64. Note you can also give over-sized piles and the items
will be distributed in the inventory identically (giving e.g., 42 * 3, same as giving 42 three times).

## Removing items

Similarly, `take` removes items:

    inv.take(new ItemPile('dirt', 1));

returns a new `ItemPile` of 1 dirt, if present, and removes the same quantity from `inv`. If called on the
inventory in the above example, the new contents will be:

    63:dirt	64:dirt	40:dirt

For more examples see the unit tests.

## Displaying items

This module only manages the inventory data structure. For graphical user interfaces to the inventory, check out:

* [voxel-inventory-toolbar](https://github.com/deathcap/voxel-inventory-toolbar)
* [inventory-window](https://github.com/deathcap/inventory-window)

## License

MIT

