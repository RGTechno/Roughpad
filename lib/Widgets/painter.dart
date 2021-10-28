import 'dart:ui';

import 'package:custom_painter_roughpad/Widgets/paintmodel.dart';
import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  final List<PaintModel?> pointsList;
  Offset offset;

  Painter(this.pointsList,this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.modelOffset + offset,
          pointsList[i + 1]!.modelOffset + offset,
          pointsList[i]!.modelPaint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        List<Offset> listOfOffset = [];
        listOfOffset.add(pointsList[i]!.modelOffset+offset);
        canvas.drawPoints(
          PointMode.points,
          listOfOffset,
          pointsList[i]!.modelPaint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
