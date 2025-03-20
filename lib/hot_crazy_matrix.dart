import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HotCrazyMatrixPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hot Crazy Matrix")),
      body: Center(
        child: CustomPaint(
          size: Size(500, 500), // Set a fixed size
          painter: HotCrazyMatrixPainter(),
        ),
      ),
    );
  }
}

class HotCrazyMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint blackPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    final double marginLeft = 40; // Space for Y-axis labels
    final double marginBottom = 40; // Space for X-axis labels

    final double graphWidth = width - marginLeft;
    final double graphHeight = height - marginBottom;

    // Draw frame (excluding scale areas)
    canvas.drawRect(
      Rect.fromLTWH(marginLeft, 0, graphWidth, graphHeight),
      blackPaint,
    );

    // Draw diagonal line (Hot-Crazy Line)
    final Paint redPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(marginLeft, graphHeight), // (0, 10)
      Offset(width, 0), // (10, 4)
      redPaint,
    );

    // Draw vertical line at X = 5 (full height)
    double x5 = marginLeft + (graphWidth / 10) * 5;
    canvas.drawLine(Offset(x5, 0), Offset(x5, graphHeight), blackPaint);

    // Draw vertical line at X = 8, stopping at the diagonal
    double x8 = marginLeft + (graphWidth / 10) * 8;
    double yDiagonal = graphHeight - ((graphHeight / 6) * (10 - 5.2)); // Y at diagonal
    canvas.drawLine(Offset(x8, yDiagonal), Offset(x8, graphHeight), blackPaint);

    // Draw horizontal lines
    double y5 = graphHeight - ((graphHeight / 6) * (5 - 4)); // Convert Y = 5
    double y7 = graphHeight - ((graphHeight / 6) * (7 - 4)); // Convert Y = 7
    double x10 = marginLeft + (graphWidth / 10) * 10; // Convert X = 10

    canvas.drawLine(Offset(x8, y5), Offset(x10, y5), blackPaint); // Line from (8,5) to (10,5)
    canvas.drawLine(Offset(x8, y7), Offset(x10, y7), blackPaint); // Line from (8,7) to (10,7)

    // Draw scales
    _drawScales(canvas, width, height, marginLeft, marginBottom);
  }

  void _drawScales(Canvas canvas, double width, double height, double marginLeft, double marginBottom) {
    final double stepX = (width - marginLeft) / 10;
    final double stepY = (height - marginBottom) / 6;
    final double scaleFontSize = 12;
    final double labelOffset = 20; // Moves X & Y labels equally away from the frame

    // X-Axis (0-10) - Labels further below the frame
    for (int i = 0; i <= 10; i++) {
      _drawText(canvas, "$i", marginLeft + (i * stepX) - 5, height - marginBottom + labelOffset, scaleFontSize);
    }

    // Y-Axis (4-10) - Labels inside the frame, shifted left
    for (int i = 4; i <= 10; i++) {
      _drawText(canvas, "$i", 5, height - marginBottom - ((i - 4) * stepY) - 5, scaleFontSize);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}