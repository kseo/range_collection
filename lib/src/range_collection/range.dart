// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

/// A range (or "interval") defines the *boundary* around a contiguous span of
/// values of some [Comparable] type; for example, "integers from 1 to 100
/// inclusive." Note that it is not possible to *iterate* over these contained
/// values.
///
/// ### Types of ranges
///
/// Each end of the range may be bounded or unbounded. If bounded, there is an
/// associated *endpoint* value, and the range is considered to be either
/// *open* (does not include the end point) or *closed* (includes the endpoint)
/// on that side. With three possibilities on each side, this yields nine basic
/// types of ranges, enumerated below. (Notation: a square bracket `[ ]`
/// indicates that the range is closed on that side; a parenthesis `( )`
/// means it is either open or unbounded. The construct `x | statement` is read
/// "the set of all *x* such that *statement*.")
///
/// **Notation** | **Definition**     | **Factory** constructor
/// `(a..b)`     | `x | a < x < b`    | [new Range.open]
/// `[a..b]`     | `x | a <= x <= b`  | [new Range.closed]
/// `(a..b]`     | `x | a < x <= b`   | [new Range.openClosed]
/// `[a..b)'     | `x | a <= x < b`   | [new Range.closedOpen]
/// `(a..+∞)`    | `x | x > a`        | [new Range.greaterThan]
/// `[a..+∞)`    | `x | x >= a`       | [new Range.atLeast]
/// `(-∞..b)`    | `x | x < b`        | [new Range.lessThan]
/// `(-∞..b]`    | `x | x <= b`       | [new Range.atMost]
/// `(-∞..+∞)`   | x                  | [new Range.all]
///
/// When both endpoints exist, the upper endpoint may not be less than the
/// lower. The endpoints may be equal only if at least one of the bounds is
/// closed:
///
/// * `[a..a]` : a singleton range
/// * `[a..a); (a..a]` : empty ranges; also valid
/// * `(a..a)` : **invalid**; an exception will be thrown
///
/// ### Warnings
///
/// * Use immutable value types only, if at all possible. If you must use a
///   mutable type, **do not** allow the endpoint instances to mutate after
///   the range is created.
/// * Your value type's comparison method should be consistent with equals
///   if at all possible. Otherwise, be aware that concepts used throughout
///   this documentation such as "equal", "same", "unique" and so on actually
///   refer to whether [Comparable.compareTo] returns zero, not whether
///   [Object.==] returns `true`.
///
/// ### Other notes
///
/// * Instances of this type are obtained using the factory constructors in
///   this class.
/// * Ranges are *convex*: whenever two values are contained, all values in
///   between them must also be contained. More formally, for any
///   `c1 <= c2 <= c3` of type `C`, `r.contains(c1) && r.contains(c3)` implies
///   `r.contains(c2)`. This means that a [Range<int>] can never be used to
///   represent, say, "all *prime* numbers from 1 to 100."
/// * Terminology note: a range `a` is said to be the *maximal* range having
///   property *P* if, for all range `b` also having property *P*,
///   `a.encloses(b)`. Likewise, `a` is *minimal* when `b.encloses(a)` for
///   all `b` having property *P*. See, for example, the definition of
///   [Range.intersection].
class Range<C extends Comparable> {
  final _Cut<C> lowerBound;
  final _Cut<C> upperBound;

  /// Returns `true` if this range is of the form `[v..v)` or `(v..v]`.
  /// (This does not encompass ranges of the form `(v..v)`, because such ranges
  /// are *invalid* and can't be constructed at all.)
  ///
  /// Note that certain discrete ranges such as the integer range `(3..4)` are
  /// **not** considered empty, even though they contain no actual values.
  bool get isEmpty => lowerBound == upperBound;

  /// Returns `true` if this range has a lower endpoint.
  bool get hasLowerBound => lowerBound != _Cut.belowAll;

  /// Returns `true` if this range has an upper endpoint.
  bool get hasUpperBound => upperBound != _Cut.aboveAll;

  /// Returns the lower endpoint of this range.
  ///
  /// Throws [ArgumentError] if this range is unbounded below (that is,
  /// [hasLowerBound] returns `false`)
  C get lowerEndpoint => lowerBound.endpoint;

  /// Returns the upper endpoint of this range.
  ///
  /// Throws [ArgumentError] if this range is unbounded above (that is,
  /// [hasUpperBound] returns `false`)
  C get upperEndpoint => upperBound.endpoint;

  /// Returns the type of this range's lower bound: [BoundType.closed] if the
  /// range includes its lower endpoint, [BoundType.open] if it does not.
  ///
  /// Throws [ArgumentError] if this range is unbounded below (that is,
  /// [hasLowerBound] returns `false`)
  BoundType get lowerBoundType => lowerBound.typeAsLowerBound;

  /// Returns the type of this range's upper bound: [BoundType.closed] if the
  /// range includes its upper endpoint, [BoundType.open] if it does not.
  ///
  /// Throws [ArgumentError] if this range is unbounded above (that is,
  /// [hasUpperBound] returns `false`)
  BoundType get upperBoundType => upperBound.typeAsUpperBound;

  static final Range _all = new Range._(_Cut.belowAll, _Cut.aboveAll);

  /// Returns a range that contains all values strictly greater than [lower]
  /// and strictly less than [upper].
  ///
  /// Throws [ArgumentError] if [lower] is greater than *or equal to*
  /// [upper].
  factory Range.open(C lower, C upper) =>
      new Range._(new _Cut<C>.aboveValue(lower), new _Cut<C>.belowValue(upper));

  /// Returns a range that contains all values greater than or equal to
  /// [lower] and less than or equal to [upper].
  ///
  /// Throws [ArgumentError] if [lower] is greater than [upper].
  factory Range.closed(C lower, C upper) =>
      new Range._(new _Cut<C>.belowValue(lower), new _Cut<C>.aboveValue(upper));

  /// Returns a range that contains all values greater than or equal to
  /// [lower] and strictly less than [upper].
  ///
  /// Throws [ArgumentError] if [lower] is greater than [upper].
  factory Range.closedOpen(C lower, C upper) =>
      new Range._(new _Cut<C>.belowValue(lower), new _Cut<C>.belowValue(upper));

  /// Returns a range that contains all values strictly greater than [lower]
  /// and less than or equal to [upper].
  ///
  /// Throws [ArgumentError] if [lower] is greater than [upper].
  factory Range.openClosed(C lower, C upper) =>
      new Range._(new _Cut<C>.aboveValue(lower), new _Cut<C>.aboveValue(upper));

  /// Returns a range that contains all values strictly less than [endpoint].
  factory Range.lessThan(C endpoint) =>
      new Range._(_Cut.belowAll, new _Cut<C>.belowValue(endpoint));

  /// Returns a range that contains all values less than or equal to [endpoint].
  factory Range.atMost(C endpoint) =>
      new Range._(_Cut.belowAll, new _Cut<C>.aboveValue(endpoint));

  /// Returns a range that contains all values strictly greater than [endpoint].
  factory Range.greaterThan(C endpoint) =>
      new Range._(new _Cut<C>.aboveValue(endpoint), _Cut.aboveAll);

  /// Returns a range that contains all values greater than or equal to
  /// [endpoint].
  factory Range.atLeast(C endpoint) =>
      new Range._(new _Cut<C>.belowValue(endpoint), _Cut.aboveAll);

  /// Returns a range with no lower bound up to the given [endpoint],
  /// which may be either inclusive (closed) or exclusive (open).
  factory Range.upTo(C endpoint, BoundType boundType) {
    switch (boundType) {
      case BoundType.open:
        return new Range<C>.lessThan(endpoint);
      case BoundType.closed:
        return new Range<C>.atMost(endpoint);
      default:
        throw new AssertionError();
    }
  }

  /// Returns a range from the given [endpoint], which may be either inclusive
  /// (closed) or exclusive (open), with no upper bound.
  factory Range.downTo(C endpoint, BoundType boundType) {
    switch (boundType) {
      case BoundType.open:
        return new Range<C>.greaterThan(endpoint);
      case BoundType.closed:
        return new Range<C>.atLeast(endpoint);
      default:
        throw new AssertionError();
    }
  }

  /// A range that contains every value of type [C].
  factory Range.all() => _all;

  /// Returns a range that contains only the given [value]. The returned range
  /// is closed on both ends.
  factory Range.singleton(C value) => new Range.closed(value, value);

  /// Returns a range that contains any value from [lower] to [upper],
  /// where each endpoint may be either inclusive (closed) or exclusive
  /// (open).
  ///
  /// Throws [ArgumentError] if [lower] is greater than [upper].
  factory Range.range(
      C lower, BoundType lowerType, C upper, BoundType upperType) {
    checkNotNull(lowerType);
    checkNotNull(upperType);

    _Cut<C> lowerBound = (lowerType == BoundType.open)
        ? new _Cut.aboveValue(lower)
        : new _Cut.belowValue(lower);
    _Cut<C> upperBound = (upperType == BoundType.open)
        ? new _Cut.belowValue(upper)
        : new _Cut.aboveValue(upper);

    return new Range._(lowerBound, upperBound);
  }

  Range._(_Cut<C> lowerBound, _Cut<C> upperBound)
      : this.lowerBound = checkNotNull(lowerBound),
        this.upperBound = checkNotNull(upperBound) {
    if (lowerBound.compareTo(upperBound) > 0 ||
        lowerBound == _Cut.aboveAll ||
        upperBound == _Cut.belowAll) {
      throw new ArgumentError(
          'Invalid range: ${_toString(lowerBound, upperBound)}');
    }
  }

  /// Returns `true` if there exists a (possibly empty) range which is
  /// enclosed by both this range and [other].
  ///
  /// For example,
  /// * `[2, 4)` and `[5, 7)` are not connected
  /// * `[2, 4)` and `[3, 5)` are connected, because both enclose `[3, 4)`
  /// * `[2, 4)` and `[4, 6)` are connected, because both enclose the empty
  ///    range `[4, 4)`
  ///
  /// Note that this range and [other] have a well-defined union and
  /// intersection (as a single, possibly-empty range) if and only if this
  /// method returns `true`.
  ///
  /// The connectedness relation is both reflexive and symmetric, but does not
  /// form an equivalence relation as it is not transitive.
  ///
  /// Note that certain discrete ranges are not considered connected, even
  /// though there are no elements "between them." For example, `[3, 5]` is
  /// not considered connected to `[6, 10]`.
  bool isConnected(Range<C> other) =>
      lowerBound.compareTo(other.upperBound) <= 0 &&
          other.lowerBound.compareTo(upperBound) <= 0;

  /// Returns the minimal range that encloses both this range and [other].
  /// For example, the span of `[1..3]` and `(5..7)` is `[1..7)`.
  ///
  /// *If* the input ranges are connected, the returned range can also be
  /// called their *union*. If they are not, note than the span might contain
  /// values that are not contained in either input range.
  ///
  /// Like [Range.intersection], this operation is commutative, associative
  /// and idempotent. Unlike it, it is always well-defined for any two input
  /// ranges.
  Range<C> span(Range<C> other) {
    int lowerCmp = lowerBound.compareTo(other.lowerBound);
    int upperCmp = upperBound.compareTo(other.upperBound);
    if (lowerCmp <= 0 && upperCmp >= 0) {
      return this;
    } else if (lowerCmp >= 0 && upperCmp <= 0) {
      return other;
    } else {
      _Cut<C> newLower = (lowerCmp <= 0) ? lowerBound : other.lowerBound;
      _Cut<C> newUpper = (upperCmp >= 0) ? upperBound : other.upperBound;
      return new Range<C>._(newLower, newUpper);
    }
  }

  Iterable<Range<C>> difference(Range<C> connectedRange) {
    final ranges = [];

    int lowerCmp = lowerBound.compareTo(connectedRange.lowerBound);
    int upperCmp = upperBound.compareTo(connectedRange.upperBound);

    if (lowerCmp < 0) {
      ranges.add(new Range._(lowerBound, connectedRange.lowerBound));
    }
    if (upperCmp > 0) {
      ranges.add(new Range._(connectedRange.upperBound, upperBound));
    }

    return ranges;
  }


  /// Returns the maximal range enclosed by both this and [connectedRange], if
  /// such a range exists.
  ///
  /// For example, the intersection of `[1..5]` and `(3..7)` is `(3..5]`. The
  /// resulting range may be empty; for example, `[1..5)` intersected with
  /// `[5..7)` yields the empty range `[5..5)`.
  ///
  /// The intersection exists if and only if the two ranges are connected.
  ///
  /// The intersection operation is commutative, associative and idempotent,
  /// and its identity element is [new Range.all].
  ///
  /// Throws [ArgumentError] if `isConnected(connectedRange)` is `false`
  Range<C> intersection(Range<C> connectedRange) {
    int lowerCmp = lowerBound.compareTo(connectedRange.lowerBound);
    int upperCmp = upperBound.compareTo(connectedRange.upperBound);
    if (lowerCmp >= 0 && upperCmp <= 0) {
      return this;
    } else if (lowerCmp <= 0 && upperCmp >= 0) {
      return connectedRange;
    } else {
      _Cut<C> newLower =
          (lowerCmp >= 0) ? lowerBound : connectedRange.lowerBound;
      _Cut<C> newUpper =
          (upperCmp <= 0) ? upperBound : connectedRange.upperBound;
      return new Range<C>._(newLower, newUpper);
    }
  }

  /// Returns `true` if the bounds of [other] do not extend outside the bounds
  /// of this range. Examples:
  ///
  /// * `[3..6]` encloses `[4..5]`
  /// * `(3..6)` encloses `(3..6)`
  /// * `[3..6]` encloses `[4..4)` even though the latter is empty
  /// * `(3..6]` does not enclose `[3..6]`
  /// * `[4..5]` does not enclose `(3..6)` (even though it contains every value
  ///   contained by the latter range)
  /// * `[3..6]` does not enclose `(1..1]` (even though it contains every value
  ///   contained by the latter range)
  ///
  /// Noe that if `a.encloses(b)`, then `b.contains(v)` implies
  /// `a.contains(v)`, but as the last two examples illustrates, the converse
  /// is not always true.
  ///
  /// Being reflexive, antisymmetric and transitive, the [Range.encloses]
  /// relation defines a *partial order* over ranges. These exists a unique
  /// maximal range according to this relation, and also numerous
  /// minimal ranges. Enclosure also implies connectedness.
  bool encloses(Range<C> other) =>
      lowerBound.compareTo(other.lowerBound) <= 0 &&
          upperBound.compareTo(other.upperBound) >= 0;

  /// Returns `true` if [value] is within the bounds of this range. For example,
  /// on the range `[0..2)`, `contains(1)` returns `true`, while `contains(2)`
  /// returns `false`.
  bool contains(C value) {
    checkNotNull(value);
    return lowerBound.isLessThan(value) && !upperBound.isLessThan(value);
  }

  @override
  int get hashCode => lowerBound.hashCode * 31 + upperBound.hashCode;

  @override
  operator ==(other) => other is Range &&
      lowerBound == other.lowerBound &&
      upperBound == other.upperBound;

  @override
  String toString() => _toString(lowerBound, upperBound);

  static String _toString(_Cut lowerBound, _Cut upperBound) =>
      '${lowerBound.describeAsLowerBound()}\u2025${upperBound.describeAsUpperBound()}';
}
