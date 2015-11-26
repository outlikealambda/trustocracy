## How Do We Store Influence?

### Goals
* insert new influence
* move influence
  * decrement old ancestors
  * increment new ancestors
* remove influence

### Zipper

* zipping down to an influence requires path to influence
* if tree stores influence hierarchy, it isn't searchable by influence ID, so we'd need to maintain a separate store of influence location in tree
* AFAICT, will not handle concurrent access

### HashMap

* stored at influence ID
* maps to (notes, parent, child-influence-total)
* can lookup influence
* can follow the chain up to decrement old ancestors
* can lookup new ancestor
* can follow the chain up to increment new ancestors

_Watch out for_

* circular dependencies
  * when looking up the new ancestor, there's no telling if the influence resides in the ancestor chain.
* when moving influence
  * the find-influence, move-influence, get-influence-total should be atomic
  * the ancestors (both old and new) can then be updated
  * this will keep concurrent updates (say influence and child influence) from improperly updating an ancestor chain
