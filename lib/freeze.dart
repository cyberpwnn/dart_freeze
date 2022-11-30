library freeze;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef FreezeBuilder = Widget Function(BuildContext context);
typedef FreezeSnapshotBuilder = Widget Function(
    BuildContext context, Widget snapshot);

class Freeze extends StatefulWidget {
  final FreezeBuilder builder;
  final FreezeSnapshotBuilder? snapBuilder;
  final double quality;
  final int snapDelay;

  const Freeze(
      {Key? key,
      required this.builder,
      this.snapDelay = 0,
      this.snapBuilder,
      this.quality = 2})
      : super(key: key);

  @override
  State<Freeze> createState() => _SnapshotWidgetState();
}

class _SnapshotWidgetState extends State<Freeze> {
  final GlobalKey _globalKey = GlobalKey();
  Uint8List? snapshot;
  bool snapping = false;

  Future<Uint8List?> capture() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      return (await (await boundary.toImage(pixelRatio: widget.quality))
              .toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
    } catch (e, es) {
      if (kDebugMode) {
        print(e);
        print(es);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget? ww;

    if (snapshot != null) {
      if (snapping) {
        snapping = false;
        ww = widget.snapBuilder != null
            ? widget.snapBuilder!(context,
                Image(image: MemoryImage(snapshot!, scale: widget.quality)))
            : Image(image: MemoryImage(snapshot!, scale: widget.quality));
      }
    }

    if (ww == null) {
      Widget w = widget.builder(context);
      Future.delayed(Duration(milliseconds: max(widget.snapDelay, 0)), () {
        try {
          capture().then((s) {
            if (s != null) {
              snapping = true;
              try {
                setState(() {
                  snapshot = s;
                });
              } catch (e, es) {
                if (kDebugMode) {
                  print(e);
                  print(es);
                }
              }
            }
          });
        } catch (e, es) {
          if (kDebugMode) {
            print(e);
            print(es);
          }
        }
      });

      ww = RepaintBoundary(
        key: _globalKey,
        child: w,
      );
    }

    return Container(
      child: ww,
    );
  }
}
