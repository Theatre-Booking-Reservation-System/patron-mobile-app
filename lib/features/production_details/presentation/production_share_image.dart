import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// PNG of the production details already painted inside [boundaryKey].
///
/// Buttons drawn outside that boundary are not part of the image.
Future<Uint8List?> captureProductionDetails(GlobalKey boundaryKey) async {
  final context = boundaryKey.currentContext;
  final boundary = context?.findRenderObject();
  if (context == null || boundary is! RenderRepaintBoundary) return null;
  final pixelRatio = MediaQuery.devicePixelRatioOf(context);
  if (boundary.debugNeedsPaint) {
    await WidgetsBinding.instance.endOfFrame;
  }
  if (!boundary.attached || boundary.debugNeedsPaint) return null;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data?.buffer.asUint8List();
    if (bytes == null || bytes.isEmpty) return null;
    return bytes;
  } finally {
    image.dispose();
  }
}
