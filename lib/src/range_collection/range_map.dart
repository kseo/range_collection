// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

/// A map entry (key-value pair) in the [RangeMap].
class RangeMapEntry<K extends Comparable, V> {
  final Range<K> key;
  final V value;

  RangeMapEntry(this.key, this.value);
}

/// A mapping from disjoint nonempty ranges to non-null values. Queries look
/// up the value associated with the range (if any) that contains a specified
/// key.
abstract class RangeMap<K extends Comparable, V> {
  /// The keys of [this].
  ///
  /// The order of iteration is defined by the individual [RangeMap]
  /// implementation, but must be consistent between changes to the map.
  Iterable<Range<K>> get keys;

  /// The values of [this].
  ///
  /// The values are iterated in the order of their corresponding keys.
  /// This means that iterating [keys] and [values] in parallel will
  /// provided matching pairs of keys and values.
  Iterable<V> get values;

  /// The number of key-value pairs in the map.
  int get length;

  /// Returns `true` if there is no key-value pair in the map.
  bool get isEmpty;

  /// Returns `true` if there is at least one key-value pair in the map.
  bool get isNotEmpty;

  /// Returns the value associated with the specified key,
  /// or `null` if there is no such value
  V operator [](K key);

  /// Maps a range to a specified value.
  void operator []=(Range<K> key, V value);

  /// Returns the range containing this key and its associated value,
  /// if such a range is present in the [RangeMap], or `null` otherwise.
  RangeMapEntry<K, V> getEntry(K key);

  /// Returns the minimal range enclosing the ranges in this [RangeMap].
  Range<K> span();

  /// Adds all the associations from rangeMap into this [RangeMap].
  void addAll(RangeMap<K, V> other);

  /// Removes all associations from this [RangeMap] in the specified range.
  void remove(Range<K> range);

  /// Removes all associations from this [RangeMap].
  void clear();
}