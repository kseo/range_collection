// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

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

