// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library range_collection.test.skip_list_range_set;

import 'package:range_collection/range_collection.dart';
import 'package:test/test.dart';

const minBound = -1;
const maxBound = 1;

void main() {
  group('SkipListRangeSet tests', () {
    List<Range<int>> queryRanges = [];

    setUpAll(() {
      queryRanges.add(new Range<int>.all());

      for (int i = minBound; i <= maxBound; i++) {
        for (final type in BoundType.values) {
          queryRanges.add(new Range.upTo(i, type));
          queryRanges.add(new Range.downTo(i, type));
        }
        queryRanges.add(new Range.singleton(i));
        queryRanges.add(new Range.openClosed(i, i));
        queryRanges.add(new Range.closedOpen(i, i));

        for (final lowerBoundType in BoundType.values) {
          for (int j = i + 1; j <= maxBound; j++) {
            for (final upperBoundType in BoundType.values) {
              queryRanges
                  .add(new Range.range(i, lowerBoundType, j, upperBoundType));
            }
          }
        }
      }
    });

    void testEnclosing(RangeSet<int> rangeSet) {
      for (final query in queryRanges) {
        bool expectEnclose = false;
        for (final expectedRange in rangeSet) {
          if (expectedRange.encloses(query)) {
            expectEnclose = true;
            break;
          }
        }
        expect(rangeSet.encloses(query), expectEnclose);
      }
    }

    test('all single ranges enclosing', () {
      for (final range in queryRanges) {
        final rangeSet = new SkipListRangeSet();
        rangeSet.add(range);
        testEnclosing(rangeSet);
      }
    });

    test('all two ranges enclosing', () {
      for (final range1 in queryRanges) {
        for (final range2 in queryRanges) {
          final rangeSet = new SkipListRangeSet();
          rangeSet.add(range1);
          rangeSet.add(range2);
          testEnclosing(rangeSet);
        }
      }
    });

    test('merges connected with overlap', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 4));
      rangeSet.add(new Range.open(2, 6));
      expect(rangeSet.toSet(), contains(new Range.closedOpen(1, 6)));
    });

    test('merges connected with disjoint', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 4));
      rangeSet.add(new Range.open(4, 6));
      expect(rangeSet.toSet(), contains(new Range.closedOpen(1, 6)));
    });

    test('ignores smaller sharing no bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 6));
      rangeSet.add(new Range.open(2, 4));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('ignores smaller sharing lower bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 6));
      rangeSet.add(new Range.open(1, 4));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('ignores smaller sharing upper bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 6));
      rangeSet.add(new Range.closed(3, 6));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('ignores equal', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 6));
      rangeSet.add(new Range.closed(1, 6));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('extend same lower bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 4));
      rangeSet.add(new Range.closed(1, 6));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('extend same upper bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.add(new Range.closed(1, 6));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('extend both directions', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 4));
      rangeSet.add(new Range.closed(1, 6));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('add empty', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closedOpen(3, 3));
      expect(rangeSet.toSet(), isEmpty);
    });

    test('fill hole exactly', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closedOpen(1, 3));
      rangeSet.add(new Range.closedOpen(4, 6));
      rangeSet.add(new Range.closedOpen(3, 4));
      expect(rangeSet.toSet(), contains(new Range.closedOpen(1, 6)));
    });

    test('fill hole with overlap', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closedOpen(1, 3));
      rangeSet.add(new Range.closedOpen(4, 6));
      rangeSet.add(new Range.closedOpen(2, 5));
      expect(rangeSet.toSet(), contains(new Range.closedOpen(1, 6)));
    });

    test('remove empty', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(1, 6));
      rangeSet.remove(new Range.closedOpen(3, 3));
      expect(rangeSet.toSet(), contains(new Range.closed(1, 6)));
    });

    test('remove part sharing lower bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 5));
      rangeSet.remove(new Range.closedOpen(3, 5));
      expect(rangeSet.toSet(), contains(new Range.singleton(5)));
    });

    test('remove part sharing upper bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 5));
      rangeSet.remove(new Range.openClosed(3, 5));
      expect(rangeSet.toSet(), contains(new Range.singleton(3)));
    });

    test('remove middle', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.atMost(6));
      rangeSet.remove(new Range.closedOpen(3, 4));
      expect(rangeSet.toSet(), [new Range.lessThan(3), new Range.closed(4, 6)]);
    });

    test('remove no overlap', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closedOpen(1, 3));
      expect(rangeSet.toSet(), [new Range.closed(3, 6)]);
    });

    test('remove part from below lower bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closed(1, 3));
      expect(rangeSet.toSet(), [new Range.openClosed(3, 6)]);
    });

    test('remove part from above upper bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closed(6, 9));
      expect(rangeSet.toSet(), [new Range.closedOpen(3, 6)]);
    });

    test('remove exact', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closed(3, 6));
      expect(rangeSet.toSet(), isEmpty);
    });

    test('remove all from below lower bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closed(2, 6));
      expect(rangeSet.toSet(), isEmpty);
    });

    test('remove all from above upper bound', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closed(3, 7));
      expect(rangeSet.toSet(), isEmpty);
    });

    test('remove all extending both directions', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 6));
      rangeSet.remove(new Range.closed(2, 7));
      expect(rangeSet.toSet(), isEmpty);
    });

    test('range containing 1', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 10));
      expect(rangeSet.rangeContaining(5), equals(new Range.closed(3, 10)));
      expect(rangeSet.contains(5), isTrue);
      expect(rangeSet.rangeContaining(1), isNull);
      expect(rangeSet.contains(1), isFalse);
    });

    test('range containing 2', () {
      final rangeSet = new SkipListRangeSet();
      rangeSet.add(new Range.closed(3, 10));
      rangeSet.remove(new Range.open(5, 7));
      expect(rangeSet.rangeContaining(5), equals(new Range.closed(3, 5)));
      expect(rangeSet.contains(5), isTrue);
      expect(rangeSet.rangeContaining(8), equals(new Range.closed(7, 10)));
      expect(rangeSet.contains(8), isTrue);
      expect(rangeSet.rangeContaining(6), isNull);
      expect(rangeSet.contains(6), isFalse);
    });
  });
}
