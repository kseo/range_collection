// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of range_collection.range_collection;

/// Indicates whether an endpoint of some range is contained in the range
/// itself ("closed") or not ("open"). If a range is unbounded on a side,
/// it is neither open nor closed on that side; the bound simply does not exist.
enum BoundType { open, closed }

