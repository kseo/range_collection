// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library range_collection.test.skip_list_range_map;

import 'package:range_collection/range_collection.dart';
import 'package:test/test.dart';

const minBound = -2;
const maxBound = 2;

RangeMap<int, int> create() => new SkipListRangeMap<int, int>();

void putModel(Map<int, int> model, Range<int> range, int value) {
  for (int i = minBound - 1; i < maxBound + 1; i++) {
    if (range.contains(i)) {
      model[i] = value;
    }
  }
}

void removeModel(Map<int, int> model, Range<int> range) {
  for (int i = minBound - 1; i < maxBound + 1; i++) {
    if (range.contains(i)) {
      model.remove(i);
    }
  }
}

void verify(Map<int, int> model, RangeMap<int, int> test) {
  for (int i = minBound - 1; i < maxBound + 1; i++) {
    expect(test[i], equals(model[i]));

    final entry = test.getEntry(i);
    expect(entry != null, equals(model.containsKey(i)));
    if (entry != null) {
      expect(test.keys.contains(entry.key), isTrue);
      expect(test.values.contains(entry.value), isTrue);
    }
  }
  for (final range in test.keys) {
    expect(range.isEmpty, isFalse);
  }
}

void main() {
  group('SkipListRangeMap tests', () {
    List<Range<int>> ranges = [];

    setUpAll(() {
      ranges.add(new Range<int>.all());

      // Add one-ended ranges
      for (int i = minBound; i <= maxBound; i++) {
        for (final type in BoundType.values) {
          ranges.add(new Range.upTo(i, type));
          ranges.add(new Range.downTo(i, type));
        }
      }

      // Add two-ended ranges
      for (int i = minBound; i <= maxBound; i++) {
        for (int j = i; j <= maxBound; j++) {
          for (final lowerType in BoundType.values) {
            for (final upperType in BoundType.values) {
              if (i == j &&
                  lowerType == BoundType.open &&
                  upperType == BoundType.open) continue;
              ranges.add(new Range.range(i, lowerType, j, upperType));
            }
          }
        }
      }
    });

    test('span single range', () {
      for (final range in ranges) {
        final rangeMap = create();
        rangeMap[range] = 1;

        try {
          expect(rangeMap.span(), equals(range));
          expect(rangeMap, isNotEmpty);
        } on NoSuchElementError {
          expect(rangeMap, isEmpty);
        }
      }
    });

    test('span two ranges', () {
      for (final range1 in ranges) {
        for (final range2 in ranges) {
          final rangeMap = create();
          rangeMap[range1] = 1;
          rangeMap[range2] = 2;

          Range<int> expected;
          if (range1.isEmpty) {
            if (range2.isEmpty) {
              expected = null;
            } else {
              expected = range2;
            }
          } else {
            if (range2.isEmpty) {
              expected = range1;
            } else {
              expected = range1.span(range2);
            }
          }

          try {
            expect(rangeMap.span(), equals(expected));
            expect(expected, isNotNull);
          } on NoSuchElementError {
            expect(expected, isNull);
          }
        }
      }
    });

    test('all ranges alone', () {
      for (final range in ranges) {
        final model = new Map<int, int>();
        putModel(model, range, 1);
        final test = create();
        test[range] = 1;
        verify(model, test);
      }
    });

    test('all ranges pairs', () {
      for (final range1 in ranges) {
        for (final range2 in ranges) {
          final model = new Map<int, int>();
          putModel(model, range1, 1);
          putModel(model, range2, 2);
          final test = create();
          test[range1] = 1;
          test[range2] = 2;
          verify(model, test);
        }
      }
    });

    test('all ranges triples', () {
      for (final range1 in ranges) {
        for (final range2 in ranges) {
          for (final range3 in ranges) {
            final model = new Map<int, int>();
            putModel(model, range1, 1);
            putModel(model, range2, 2);
            putModel(model, range3, 3);
            final test = create();
            test[range1] = 1;
            test[range2] = 2;
            test[range3] = 3;
            verify(model, test);
          }
        }
      }
    });

    test('put all', () {
      for (final range1 in ranges) {
        for (final range2 in ranges) {
          for (final range3 in ranges) {
            final model = new Map<int, int>();
            putModel(model, range1, 1);
            putModel(model, range2, 2);
            putModel(model, range3, 3);
            final test = create();
            final test2 = create();
            // put range2 and range3 into test2, and then put test2 into test
            test[range1] = 1;
            test2[range2] = 2;
            test2[range3] = 3;
            test.addAll(test2);
            verify(model, test);
          }
        }
      }
    });

    test('put and remove', () {
      for (final rangeToPut in ranges) {
        for (final rangeToRemove in ranges) {
          final model = new Map<int, int>();
          putModel(model, rangeToPut, 1);
          removeModel(model, rangeToRemove);
          final test = create();
          test[rangeToPut] = 1;
          test.remove(rangeToRemove);
          verify(model, test);
        }
      }
    });

    test('put two and remove', () {
      for (final rangeToPut1 in ranges) {
        for (final rangeToPut2 in ranges) {
          for (final rangeToRemove in ranges) {
            final model = new Map<int, int>();
            putModel(model, rangeToPut1, 1);
            putModel(model, rangeToPut2, 2);
            removeModel(model, rangeToRemove);
            final test = create();
            test[rangeToPut1] = 1;
            test[rangeToPut2] = 2;
            test.remove(rangeToRemove);
            verify(model, test);
          }
        }
      }
    });
  });
}
