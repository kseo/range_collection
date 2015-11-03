// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

/// A set comprising zero or more nonempty, disconnected ranges of type [C].
///
/// Implementations that choose to support the [add] operation are required to
/// ignore empty ranges and coalesce connected ranges. For example:
///
/// ```dart
///  RangeSet<int> rangeSet = new SkipListRangeSet<int>();
///  rangeSet.add(new Range.closed(1, 10));
///  // {[1, 10]}
///
///  rangeSet.add(new Range.closedOpen(11, 15));
///  // disconnected range; {[1, 10], [11, 15)}
///
///  rangeSet.add(new Range.closedOpen(15, 20));
///  // connected range; {[1, 10], [11, 20)}
///
///  rangeSet.add(new Range.openClosed(0, 0));
///  // empty range; {[1, 10], [11, 20)}
///
///  rangeSet.remove(new Range.open(5, 10));
///  // splits [1, 10]; {[1, 5], [10, 10], [11, 20)}}
/// ```
abstract class RangeSet<C extends Comparable> implements Iterable<Range<C>> {
  /// Returns the number of elements in the set.
  int get length;

  /// Returns `true` if this range set contains no ranges.
  bool get isEmpty;

  /// Returns `true` if this range set contains at least one range.
  bool get isNotEmpty;

  /// Adds the specified range to this [RangeSet].
  void add(Range<C> range);

  /// Adds all of the ranges from the specified range set to this range set
  void addAll(RangeSet<C> other);

  /// Returns the minimal range which encloses all ranges in this range set.
  Range<C> span();

  /// Returns the unique range from this range set that contains value,
  /// or `null` if this range set does not contain value.
  Range<C> rangeContaining(C value);

  /// Determines whether any of this range set's member ranges contains value.
  bool contains(C value);

  /// Returns `true` if there exists a member range in this range set which
  /// encloses the specified range.
  bool encloses(Range<C> otherRange);

  /// Returns `true` if for each member range in other there exists a member
  /// range in this range set which encloses it.
  bool enclosesAll(RangeSet<C> other);

  /// Removes the specified range from this [RangeSet].
  void remove(Range<C> range);

  /// Removes all of the ranges from the specified range set from this range set.
  void removeAll(RangeSet<C> other);

  /// Removes all ranges from this [RangeSet].
  void clear();
}
