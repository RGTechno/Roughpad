import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatelessWidget {
  final List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: mediaQuery.height,
        width: mediaQuery.width,
        color: Colors.white,
        child: const CustomPaint(),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 15,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.4),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(
              color: Colors.blueGrey,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              colors.length,
              (index) => ColorPicker(
                color: colors[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaintModel {
  final Offset modelOffset;
  final Paint modelPaint;

  PaintModel({
    required this.modelOffset,
    required this.modelPaint,
  });
}

class Painter extends CustomPainter {
  final List<PaintModel> pointsList;

  Painter(this.pointsList);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i].modelOffset,
          pointsList[i + 1].modelOffset,
          pointsList[i].modelPaint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        List<Offset> listOfOffset = [];
        listOfOffset.add(pointsList[i].modelOffset);
        canvas.drawPoints(
          PointMode.points,
          listOfOffset,
          pointsList[i].modelPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPicker extends StatelessWidget {
  final Color color;

  const ColorPicker({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 20,
    );
  }
}
