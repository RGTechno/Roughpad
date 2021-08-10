import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
  ];

  Color selectedColor = Colors.blue;
  Color animColor = Colors.transparent;

  List<PaintModel?> points = [];
  final paintStream = BehaviorSubject<List<PaintModel?>>();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    final scaffoldKey = GlobalKey();

    return Scaffold(
      key: scaffoldKey,
      body: GestureDetector(
        onPanStart: (details) {
          Paint paint = Paint();
          paint.color = selectedColor;
          paint.strokeWidth = 2;
          paint.strokeCap = StrokeCap.round;

          points.add(
            PaintModel(
              modelOffset: details.localPosition,
              modelPaint: paint,
            ),
          );

          paintStream.add(points);
        },
        onPanUpdate: (details) {
          Paint paint = Paint();
          paint.color = selectedColor;
          paint.strokeWidth = 2;
          paint.strokeCap = StrokeCap.round;

          points.add(
            PaintModel(
              modelOffset: details.localPosition,
              modelPaint: paint,
            ),
          );

          paintStream.add(points);
        },
        onPanEnd: (details) {
          points.add(null);
          paintStream.add(points);
        },
        child: Stack(
          children: [
            Container(
              height: mediaQuery.height,
              width: mediaQuery.width,
              color: Colors.white,
              // ignore: deprecated_member_use
              child: StreamBuilder<List<PaintModel?>>(
                stream: paintStream.stream,
                builder: (context, snapshot) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 10000),
                    color: Colors.transparent,
                    curve: Curves.bounceOut,
                    child: CustomPaint(
                      painter: Painter(
                        (snapshot.data ?? []),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: mediaQuery.height * 0.1,
              left: mediaQuery.width * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        points = [];
                      });
                      paintStream.add(points);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(
                          horizontal: mediaQuery.width * 0.1,
                          vertical: 5,
                        ),
                      ),
                    ),
                    child: const Text("Reset"),
                  ),
                  // const SizedBox(width: 10),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // setState(() {
                  //     //   animColor = Colors.brown.withOpacity(0.4);
                  //     // });
                  //     // Timer(const Duration(milliseconds: 10000), () {
                  //     //   setState(() {
                  //     //     animColor = Colors.transparent;
                  //     //   });
                  //     // });
                  //   },
                  //   style: ButtonStyle(
                  //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  //       RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(15),
                  //       ),
                  //     ),
                  //     padding: MaterialStateProperty.all<EdgeInsets>(
                  //       EdgeInsets.symmetric(
                  //         horizontal: mediaQuery.width * 0.1,
                  //         vertical: 5,
                  //       ),
                  //     ),
                  //   ),
                  //   child: const Text("Animate"),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 15,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: mediaQuery.height * 0.03,
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
              (index) => colorPicker(colors[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget colorPicker(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: isSelected ? 30 : 20,
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
  final List<PaintModel?> pointsList;

  Painter(this.pointsList);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.modelOffset,
          pointsList[i + 1]!.modelOffset,
          pointsList[i]!.modelPaint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        List<Offset> listOfOffset = [];
        listOfOffset.add(pointsList[i]!.modelOffset);
        canvas.drawPoints(
          PointMode.points,
          listOfOffset,
          pointsList[i]!.modelPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
