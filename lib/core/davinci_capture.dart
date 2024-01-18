import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DavinciCapture {
  /// If the widget is in the widget tree, use this method.
  /// if the fileName is not set, it sets the file name as "davinci".
  /// you can define whether to openFilePreview or returnImageUint8List
  /// openFilePreview is true by default.
  /// Context is required.
  static Future<Uint8List?> click(GlobalKey key,
      {required BuildContext context,
      double? pixelRatio,
      bool returnImageUint8List = false}) async {
    try {
      pixelRatio ??= View.of(context).devicePixelRatio;

      // finding the widget in the current context by the key.
      RenderRepaintBoundary repaintBoundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      /// With the repaintBoundary we got from the context, we start the createImageProcess
      return await _createImageProcess(
        repaintBoundary: repaintBoundary,
        pixelRatio: pixelRatio,
      );
    } catch (e) {
      /// if the above process is failed, the error is printed.
      print(e);
      return null;
    }
  }

  /// * If the widget is not in the widget tree, use this method.
  /// if the fileName is not set, it sets the file name as "davinci".
  /// you can define whether to openFilePreview or returnImageUint8List
  /// If the image is blurry, calculate the pixelratio dynamically. See the readme
  /// for more info on how to do it.
  /// Context is required.
  static Future<Uint8List?> offStage(
    Widget widget, {
    Duration? wait,
    double? pixelRatio,
    Size? size,
    required BuildContext context,
  }) async {
    /// finding the widget in the current context by the key.
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    /// create a new pipeline owner
    final PipelineOwner pipelineOwner = PipelineOwner();

    /// create a new build owner
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    Size logicalSize =
        View.of(context).physicalSize / View.of(context).devicePixelRatio;
    pixelRatio ??= View.of(context).devicePixelRatio;
    try {
      final RenderView renderView = RenderView(
        view: View.of(context),
        child: RenderPositionedBox(
            alignment: Alignment.center, child: repaintBoundary),
        configuration: ViewConfiguration(
          size: size ?? logicalSize,
          devicePixelRatio: 1.0,
        ),
      );

      /// setting the rootNode to the renderview of the widget
      pipelineOwner.rootNode = renderView;

      /// setting the renderView to prepareInitialFrame
      renderView.prepareInitialFrame();

      /// setting the rootElement with the widget that has to be captured
      final RenderObjectToWidgetElement<RenderBox> rootElement =
          RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      ).attachToRenderTree(buildOwner);

      ///adding the rootElement to the buildScope
      buildOwner.buildScope(rootElement);

      /// if the wait is null, sometimes
      /// the then waiting for the given [wait] amount of time and
      /// then creating an image via a [RepaintBoundary].

      if (wait != null) {
        await Future.delayed(wait);
      }

      ///adding the rootElement to the buildScope
      buildOwner.buildScope(rootElement);

      /// finialize the buildOwner
      buildOwner.finalizeTree();

      ///Flush Layout
      pipelineOwner.flushLayout();

      /// Flush Compositing Bits
      pipelineOwner.flushCompositingBits();

      /// Flush paint
      pipelineOwner.flushPaint();

      /// we start the createImageProcess once we have the repaintBoundry of
      /// the widget we attached to the widget tree.
      return await _createImageProcess(
          repaintBoundary: repaintBoundary, pixelRatio: pixelRatio);
    } catch (e) {
      return null;
    }
  }

  /// create image process
  static Future<Uint8List> _createImageProcess(
      {RenderRepaintBoundary? repaintBoundary, double? pixelRatio}) async {
    // the boundary is converted to Image.

    final ui.Image image =
        await repaintBoundary!.toImage(pixelRatio: pixelRatio!);

    /// The raw image is converted to byte data.
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    /// The byteData is converted to uInt8List image aka memory Image.
    final Uint8List u8Image = byteData!.buffer.asUint8List();

    /// If the returnImageUint8List is true, return the image as uInt8List
    return u8Image;
  }
}
