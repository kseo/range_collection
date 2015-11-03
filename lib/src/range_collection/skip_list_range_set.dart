// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

class SkipListRangeSet<C extends Comparable> extends IterableBase<Range<C>>
    implements RangeSet<C> {
  final IntervalSkipList<_Cut<C>, Range<C>> _list =
      new IntervalSkipList<_Cut<C>, Range<C>>(
          minIndex: _Cut._bottom, maxIndex: _Cut._top);

  @override
  int get length => _list.intervalsByMarker.length;

  @override
  bool get isEmpty => _list.intervalsByMarker.isEmpty;

  @override
  bool get isNotEmpty => _list.intervalsByMarker.isNotEmpty;

  @override
  Iterator<Range<C>> get iterator => _list.intervalsByMarker.keys.iterator;

  @override
  void add(Range<C> rangeToAdd) {
    checkNotNull(rangeToAdd);
    if (rangeToAdd.isEmpty) return;

    var newLowerBound = rangeToAdd.lowerBound;
    var newUpperBound = rangeToAdd.upperBound;

    if (rangeToAdd.hasLowerBound) {
      final lowerRanges = _list.findContaining([
        rangeToAdd.lowerBound == BoundType.open
            ? new _Cut<C>.aboveValue(rangeToAdd.lowerEndpoint)
            : new _Cut<C>.belowValue(rangeToAdd.lowerEndpoint)
      ]);
      if (lowerRanges.isNotEmpty) {
        newLowerBound = _min(lowerRanges.map((range) => range.lowerBound));
      }
    }
    if (rangeToAdd.hasUpperBound) {
      final upperRanges = _list.findContaining([
        rangeToAdd.upperBound == BoundType.open
            ? new _Cut<C>.belowValue(rangeToAdd.upperEndpoint)
            : new _Cut<C>.aboveValue(rangeToAdd.upperEndpoint)
      ]);
      if (upperRanges.isNotEmpty) {
        newUpperBound = _max(upperRanges.map((range) => range.upperBound));
      }
    }

    final newRange = new Range._(newLowerBound, newUpperBound);
    remove(newRange);

    _list.insert(newRange, newRange.lowerBound, newRange.upperBound);
  }

  @override
  void addAll(RangeSet<C> other) {
    for (final range in other) {
      add(range);
    }
  }

  @override
  Range<C> span() {
    final lowerEntries = _list.findFirstAfterMin();
    final upperEntries = _list.findLastBeforeMax();
    if (lowerEntries.isEmpty || upperEntries.isEmpty) {
      throw new NoSuchElementError();
    }
    return new Range<C>._(
        lowerEntries.single.lowerBound, upperEntries.single.upperBound);
  }

  @override
  Range<C> rangeContaining(C value) {
    final markers = _list.findContaining(
        [new _Cut.belowValue(value), new _Cut.aboveValue(value)]);
    if (markers.isNotEmpty) {
      for (final marker in markers) {
        if (marker.contains(value)) {
          return marker;
        }
      }
    }
    return null;
  }

  @override
  bool contains(C value) => rangeContaining(value) != null;

  @override
  bool encloses(Range<C> range) {
    checkNotNull(range);
    return _list.findContaining([range.lowerBound, range.upperBound])
        .isNotEmpty;
  }

  @override
  bool enclosesAll(RangeSet<C> other) {
    for (final range in other) {
      if (!encloses(range)) {
        return false;
      }
    }
    return true;
  }

  @override
  void remove(Range<C> rangeToRemove) {
    if (rangeToRemove.isEmpty) return;

    final ranges = _list.findIntersecting(
        rangeToRemove.lowerBound, rangeToRemove.upperBound);

    for (final range in ranges) {
      final diffRanges = range.difference(rangeToRemove);
      _list.remove(range);
      for (final diffRange in diffRanges) {
        _list.insert(diffRange, diffRange.lowerBound, diffRange.upperBound);
      }
    }
  }

  @override
  void removeAll(RangeSet<C> other) {
    for (final range in other) {
      remove(range);
    }
  }

  @override
  void clear() {
    _list.clear();
  }
}

dynamic _max(Iterable i, [Comparator compare = Comparable.compare]) =>
    i.isEmpty ? null : i.reduce((a, b) => compare(a, b) > 0 ? a : b);

dynamic _min(Iterable i, [Comparator compare = Comparable.compare]) =>
    i.isEmpty ? null : i.reduce((a, b) => compare(a, b) < 0 ? a : b);
