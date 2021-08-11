import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  Color pickerColor = Colors.blue;

  Color animColor = Colors.transparent;

  List<PaintModel?> points = [];
  final paintStream = BehaviorSubject<List<PaintModel?>>();

  @override
  void dispose() {
    paintStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    bool showColors = false;

    final scaffoldKey = GlobalKey();

    return Scaffold(
      key: scaffoldKey,
      body: GestureDetector(
        onDoubleTap: () {
          showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  title: const Text("Clear"),
                  content: const Text("Do you want to clear the board?"),
                  actions: [
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () {
                        setState(() {
                          points = [];
                        });
                        paintStream.add(points);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("No"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                );
              });
        },
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
        child: Container(
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
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedColor,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext cntx) {
                return AlertDialog(
                  title: const Text("Pick A Color"),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (Color colorSelected) {
                        setState(() {
                          pickerColor = colorSelected;
                        });
                      },
                      showLabel: true,
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedColor = pickerColor;
                        });
                        Navigator.of(cntx).pop();
                      },
                      child: const Text("Done"),
                    ),
                  ],
                );
              });
        },
      ),

      // bottomNavigationBar: BottomAppBar(
      //   elevation: 15,
      //   child: Container(
      //     padding: EdgeInsets.symmetric(
      //       vertical: mediaQuery.height * 0.03,
      //       horizontal: 8,
      //     ),
      //     decoration: BoxDecoration(
      //       color: Colors.brown.withOpacity(0.4),
      //       borderRadius: const BorderRadius.only(
      //         topLeft: Radius.circular(30),
      //         topRight: Radius.circular(30),
      //       ),
      //       border: Border.all(
      //         color: Colors.blueGrey,
      //         width: 1.5,
      //       ),
      //     ),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         ...List.generate(
      //           colors.length,
      //           (index) => colorPicker(colors[index]),
      //         ),
      //         // IconButton(
      //         //   onPressed: () {},
      //         //   icon: const Icon(
      //         //     Icons.cancel_outlined,
      //         //     size: 30,
      //         //   ),
      //         // )
      //       ],
      //     ),
      //   ),
      // ),
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
