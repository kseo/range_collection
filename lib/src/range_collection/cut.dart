// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

abstract class _Cut<C extends Comparable> implements Comparable<_Cut<C>> {
  final C endpoint;

  BoundType get typeAsLowerBound;
  BoundType get typeAsUpperBound;

  static get _bottom => _Bottom.instance;
  static get _top => _Top.instance;

  static get belowAll => _BelowAll.instance;
  static get aboveAll => _AboveAll.instance;

  factory _Cut.belowValue(C endpoint) => new _BelowValue(endpoint);
  factory _Cut.aboveValue(C endpoint) => new _AboveValue(endpoint);

  _Cut(this.endpoint);

  bool isLessThan(C value);

  String describeAsLowerBound();
  String describeAsUpperBound();

  @override
  int compareTo(_Cut<C> other) {
    if (identical(other, _Cut.belowAll) || identical(other, _Cut._bottom)) {
      return 1;
    }
    if (identical(other, _Cut.aboveAll) || identical(other, _Cut._top)) {
      return -1;
    }
    int result = endpoint.compareTo(other.endpoint);
    if (result != 0) {
      return result;
    }

    // same value. below comes before above
    return _Booleans.compare(this is _AboveValue, other is _AboveValue);
  }

  operator ==(other) => other is _Cut && compareTo(other) == 0;
}

class _BelowAll extends _Cut {
  static final _BelowAll instance = new _BelowAll();

  @override
  BoundType get typeAsLowerBound => throw new AssertionError();

  @override
  BoundType get typeAsUpperBound => throw new AssertionError();

  _BelowAll() : super(null);

  @override
  bool isLessThan(Comparable value) => !identical(value, _Cut._bottom);

  @override
  String describeAsLowerBound() => '-\u221e';

  @override
  String describeAsUpperBound() => throw new AssertionError();

  @override
  int compareTo(_Cut<Comparable> o) {
    if (identical(o, _Cut._bottom)) {
      return 1;
    } else if (identical(o, this)) {
      return 0;
    } else {
      return -1;
    }
  }

  @override
  String toString() => '-\u221e';
}

class _BelowValue<C extends Comparable<C>> extends _Cut<C> {
  @override
  BoundType get typeAsLowerBound => BoundType.closed;

  @override
  BoundType get typeAsUpperBound => BoundType.open;

  _BelowValue(C endpoint) : super(checkNotNull(endpoint));

  @override
  bool isLessThan(C value) => endpoint.compareTo(value) <= 0;

  @override
  String describeAsLowerBound() => '[$endpoint';

  @override
  String describeAsUpperBound() => '$endpoint)';

  @override
  int get hashCode => endpoint.hashCode;

  @override
  String toString() => '\\$endpoint/';
}

class _AboveAll extends _Cut {
  static final _AboveAll instance = new _AboveAll();

  @override
  BoundType get typeAsLowerBound => throw new AssertionError();

  @override
  BoundType get typeAsUpperBound => throw new AssertionError();

  _AboveAll() : super(null);

  @override
  bool isLessThan(Comparable value) => identical(value, _Cut._top);

  @override
  String describeAsLowerBound() => throw new AssertionError();

  @override
  String describeAsUpperBound() => '+\u221e';

  @override
  int compareTo(_Cut<Comparable> o) {
    if (identical(o, _Cut._top)) {
      return -1;
    } else if (identical(o, this)) {
      return 0;
    } else {
      return 1;
    }
  }

  @override
  String toString() => "+\u221e";
}

class _AboveValue<C extends Comparable<C>> extends _Cut<C> {
  @override
  BoundType get typeAsLowerBound => BoundType.open;

  @override
  BoundType get typeAsUpperBound => BoundType.closed;

  _AboveValue(C endpoint) : super(checkNotNull(endpoint));

  @override
  bool isLessThan(C value) => endpoint.compareTo(value) < 0;

  @override
  String describeAsLowerBound() => '($endpoint';

  @override
  String describeAsUpperBound() => '$endpoint]';

  @override
  int get hashCode => ~endpoint.hashCode;

  @override
  String toString() => '/$endpoint\\';
}

class _Bottom extends _Cut {
  static final _BelowAll instance = new _BelowAll();

  @override
  BoundType get typeAsLowerBound => throw new AssertionError();

  @override
  BoundType get typeAsUpperBound => throw new AssertionError();

  _Bottom() : super(null);

  @override
  bool isLessThan(Comparable value) {
    return true;
  }

  @override
  String describeAsLowerBound() => '-\u221e';

  @override
  String describeAsUpperBound() => throw new AssertionError();

  @override
  int compareTo(_Cut<Comparable> o) => identical(o, this) ? 0 : -1;

  @override
  String toString() => 'bottom';
}

class _Top extends _Cut {
  static final _AboveAll instance = new _AboveAll();

  @override
  BoundType get typeAsLowerBound => throw new AssertionError();

  @override
  BoundType get typeAsUpperBound => throw new AssertionError();

  _Top() : super(null);

  @override
  bool isLessThan(Comparable value) {
    return false;
  }

  @override
  String describeAsLowerBound() => throw new AssertionError();

  @override
  String describeAsUpperBound() => '+\u221e';

  @override
  int compareTo(_Cut<Comparable> o) => identical(o, this) ? 0 : 1;

  @override
  String toString() => "top";
}

class _Booleans {
  static int compare(bool a, bool b) => (a == b) ? 0 : (a ? 1 : -1);
}

