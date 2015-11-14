# range_collection

A collection library for Range data type. This project is heavily inspired by Guava's [Range][range], [RangeSet][rangeset] and [RangeMap][rangemap] classes.

[range]: https://github.com/google/guava/wiki/RangesExplained
[rangeset]: https://github.com/google/guava/wiki/NewCollectionTypesExplained#rangeset
[rangemap]: https://github.com/google/guava/wiki/NewCollectionTypesExplained#rangemap

## Usage

A simple usage example:

```dart
library range_collection.example;

import 'package:range_collection/range_collection.dart';

main() {
  RangeSet<int> rangeSet = new SkipListRangeSet<int>();
  rangeSet.add(new Range.closed(1, 10));
  print(rangeSet); // {[1, 10]}

  rangeSet.add(new Range.closedOpen(11, 15));
  print(rangeSet); // disconnected range; {[1, 10], [11, 15)}

  rangeSet.add(new Range.closedOpen(15, 20));
  print(rangeSet); // connected range; {[1, 10], [11, 20)}

  rangeSet.add(new Range.openClosed(0, 0));
  print(rangeSet); // empty range; {[1, 10], [11, 20)}

  rangeSet.remove(new Range.open(5, 10));
  print(rangeSet); // splits [1, 10]; {[1, 5], [10, 10], [11, 20)}}
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kseo/range_collection/issues
