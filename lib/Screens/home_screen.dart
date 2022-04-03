import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:custom_painter_roughpad/Widgets/painter.dart';
import 'package:custom_painter_roughpad/Widgets/paintmodel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

enum PadState { scroll, draw }

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PadState padState = PadState.draw;
  // ignore: prefer_const_constructors
  Offset offDiff = Offset(0, 0);
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
  double selectedStrokeWidth = 2;
  bool eraser = false;

  Color animColor = Colors.transparent;

  List<PaintModel?> points = [];
  final paintStream = BehaviorSubject<List<PaintModel?>>();

  @override
  void dispose() {
    paintStream.close();
    super.dispose();
  }

  final scaffoldKey = GlobalKey();

  Future<void> saveImage() async {
    RenderRepaintBoundary canvas = scaffoldKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image canvasImage = await canvas.toImage();
    ByteData? ciByteData =
        await canvasImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List canvasPng = ciByteData!.buffer.asUint8List();

    if (!(await Permission.storage.status.isGranted)) {
      await Permission.storage.request();
    }
    // ignore: unused_local_variable
    final imageSaved = await ImageGallerySaver.saveImage(
      Uint8List.fromList(canvasPng),
      name: "Roughwork",
    );
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: Text(
              "Image Saved",
              style: GoogleFonts.gafata(),
            ),
            content: Text(
              "Image Saved Successfully!!",
              style: GoogleFonts.gafata(),
            ),
            actions: [
              TextButton(
                child: Text(
                  "OK",
                  style: GoogleFonts.gafata(),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  clearScreen() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: Text(
              "Clear",
              style: GoogleFonts.gafata(),
            ),
            content: Text(
              "Do you want to clear the board?",
              style: GoogleFonts.gafata(),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Yes",
                  style: GoogleFonts.gafata(),
                ),
                onPressed: () {
                  setState(() {
                    points = [];
                  });
                  paintStream.add(points);
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: Text(
                  "No",
                  style: GoogleFonts.gafata(),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Roughpad",
          style: GoogleFonts.arizonia(
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          kIsWeb
              ? Container()
              : IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: saveImage,
                ),
          TextButton(
            onPressed: () {
              setState(() {
                padState =
                    padState == PadState.draw ? PadState.scroll : PadState.draw;
              });
            },
            child: Text(padState == PadState.draw ? "Scroll" : "Draw"),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                eraser = !eraser;
              });
            },
            icon: !eraser
                ? const FaIcon(FontAwesomeIcons.eraser)
                : const Icon(Icons.brush),
          ),
          // IconButton(
          //   icon: const Icon(Icons.undo_rounded),
          //   onPressed: () {
          //     setState(() {
          //       points.removeLast();
          //       paintStream.add(points);
          //     });
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            onPressed: clearScreen,
          ),
        ],
      ),
      body: RepaintBoundary(
        key: scaffoldKey,
        child: GestureDetector(
          onDoubleTap: clearScreen,
          onPanStart: (details) {
            Paint paint = Paint();
            if (padState == PadState.draw) {
              if (eraser) {
                paint.color = Colors.white;
                paint.blendMode = BlendMode.clear;
                paint.strokeWidth = selectedStrokeWidth;
                paint.strokeCap = StrokeCap.round;
              } else {
                paint.color = selectedColor;
                paint.strokeWidth = selectedStrokeWidth;
                paint.strokeCap = StrokeCap.round;
              }

              points.add(
                PaintModel(
                  modelOffset: details.localPosition - offDiff,
                  modelPaint: paint,
                ),
              );
            }

            paintStream.add(points);
          },
          onPanUpdate: (details) {
            Paint paint = Paint();
            if (padState == PadState.draw) {
              if (eraser) {
                paint.color = Colors.white;
                paint.blendMode = BlendMode.clear;
                paint.strokeWidth = selectedStrokeWidth;
                paint.strokeCap = StrokeCap.round;
              } else {
                paint.color = selectedColor;
                paint.strokeWidth = selectedStrokeWidth;
                paint.strokeCap = StrokeCap.round;
              }

              points.add(
                PaintModel(
                  modelOffset: details.localPosition - offDiff,
                  modelPaint: paint,
                ),
              );
              paintStream.add(points);
            } else {
              offDiff += details.delta;
            }
          },
          onPanEnd: (details) {
            if (padState == PadState.draw) {
              points.add(null);
            }
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
                          offDiff,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Slider(
                  label: "$selectedStrokeWidth",
                  activeColor: selectedColor,
                  value: selectedStrokeWidth,
                  divisions: 16,
                  onChanged: (value) {
                    setState(() {
                      selectedStrokeWidth = value;
                    });
                    // print(value);
                  },
                  min: 2,
                  max: 50,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Color Picker",
        backgroundColor: selectedColor,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext cntx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  title: Text(
                    "Pick A Color",
                    style: GoogleFonts.gafata(),
                  ),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (Color colorSelected) {
                        setState(() {
                          pickerColor = colorSelected;
                        });
                      },
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
                      child: Text(
                        "Done",
                        style: GoogleFonts.gafata(),
                      ),
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}
