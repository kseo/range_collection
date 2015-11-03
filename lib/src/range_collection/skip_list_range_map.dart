// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

class SkipListRangeMap<C extends Comparable, V> implements RangeMap<C, V> {
  final IntervalSkipList<_Cut<C>, _Marker<C, V>> _list =
      new IntervalSkipList<_Cut<C>, _Marker<C, V>>(
          minIndex: _Cut._bottom, maxIndex: _Cut._top);

  @override
  bool get isEmpty => _list.intervalsByMarker.isEmpty;

  @override
  bool get isNotEmpty => _list.intervalsByMarker.isNotEmpty;

  @override
  int get length => _list.intervalsByMarker.length;

  @override
  Iterable<Range<C>> get keys {
    final markers = _list.intervalsByMarker.keys;
    return markers.map((marker) => marker.range);
  }

  @override
  Iterable<V> get values {
    final markers = _list.intervalsByMarker.keys;
    return markers.map((marker) => marker.value);
  }

  _Marker<C, V> _getMarker(C key) {
    final markers = _list
        .findContaining([new _Cut.belowValue(key), new _Cut.aboveValue(key)]);
    if (markers.isNotEmpty) {
      for (final marker in markers) {
        if (marker.range.contains(key)) {
          return marker;
        }
      }
    }
    return null;
  }

  @override
  V operator [](C key) {
    final marker = _getMarker(key);
    return (marker != null) ? marker.value : null;
  }

  @override
  void operator []=(Range<C> key, V value) {
    if (key.isEmpty) return;
    remove(key);

    final marker = new _Marker<C, V>(key, value);
    _list.insert(marker, key.lowerBound, key.upperBound);
  }

  @override
  RangeMapEntry<C, V> getEntry(C key) {
    final marker = _getMarker(key);
    return (marker != null)
        ? new RangeMapEntry(marker.range, marker.value)
        : null;
  }

  @override
  Range<C> span() {
    final lowerEntries = _list.findFirstAfterMin();
    final upperEntries = _list.findLastBeforeMax();
    if (lowerEntries.isEmpty || upperEntries.isEmpty) {
      throw new NoSuchElementError();
    }
    return new Range<C>._(lowerEntries.single.range.lowerBound,
        upperEntries.single.range.upperBound);
  }

  @override
  void addAll(RangeMap<C, V> other) {
    for (final entry in zip([other.keys, other.values])) {
      final range = entry[0];
      final value = entry[1];
      this[range] = value;
    }
  }

  @override
  void remove(Range<C> rangeToRemove) {
    if (rangeToRemove.isEmpty) return;

    final markers = _list.findIntersecting(
        rangeToRemove.lowerBound, rangeToRemove.upperBound);

    for (final marker in markers) {
      final diffRanges = marker.range.difference(rangeToRemove);
      _list.remove(marker);
      for (final diffRange in diffRanges) {
        final newMarker = new _Marker(diffRange, marker.value);
        _list.insert(newMarker, diffRange.lowerBound, diffRange.upperBound);
      }
    }
  }

  @override
  void clear() {
    _list.clear();
  }
}

class NoSuchElementError extends Error {}

class _Marker<C extends Comparable, V> {
  final Range<C> range;
  final V value;

  _Marker(this.range, [this.value = null]);

  @override
  int get hashCode => range.hashCode;

  @override
  operator ==(other) => other is _Marker && range == other.range;

  String toString() => '[$range, $value]';
}
