import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Class only use in order to give access to StaggeredGridTile to users
class ScaledTile extends StaggeredGridTile {
  /// Creates a [ScaledTile] with the given [crossAxisCellCount] that
  /// fit its main axis extent to its content.
  ///
  /// This tile will have a fixed main axis extent.
  const ScaledTile.fit(
    Key? key,
    int crossAxisCellCount,
    Widget child,
  ) : super.fit(key: key, crossAxisCellCount: crossAxisCellCount, child: child);

  /// Creates a [ScaledTile] with the given [crossAxisCellCount] and
  /// [mainAxisExtent].
  ///
  /// This tile will have a fixed main axis extent.
  const ScaledTile.extent(
    Key? key,
    int crossAxisCellCount,
    double mainAxisExtent,
    Widget child,
  ) : super.extent(
            key: key,
            crossAxisCellCount: crossAxisCellCount,
            mainAxisExtent: mainAxisExtent,
            child: child);

  /// Creates a [ScaledTile] with the given [crossAxisCellCount] and
  /// [mainAxisCellCount].
  ///
  /// The main axis extent of this tile will be the length of
  /// [mainAxisCellCount] cells (inner spacings included).
  const ScaledTile.count(
    Key? key,
    int crossAxisCellCount,
    num mainAxisCellCount,
    Widget child,
  ) : super.count(
            key: key,
            crossAxisCellCount: crossAxisCellCount,
            mainAxisCellCount: mainAxisCellCount,
            child: child);
}
