import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hot Crazy Matrix',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HotCrazyMatrixPage(),
    );
  }
}

class DataPoint {
  final String name;
  final double x; // Hotness
  final double y; // Craziness

  DataPoint(this.name, this.x, this.y);
}

class HotCrazyMatrixPage extends StatefulWidget {
  @override
  _HotCrazyMatrixPageState createState() => _HotCrazyMatrixPageState();
}

class _HotCrazyMatrixPageState extends State<HotCrazyMatrixPage> {
  List<DataPoint> dataPoints = [];

  void addDataPoint(String name, double x, double y) {
    setState(() {
      dataPoints.add(DataPoint(name, x, y));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/hot_crazy_matrix.png',
              height: 40, // Adjust the height as needed
            ),
            SizedBox(width: 10), // Space between the image and title
            Text("Hot Crazy Matrix"),
          ],
        ),
      ),
      body: Center(
        child: CustomPaint(
          size: Size(500, 500), // Set a fixed size
          painter: HotCrazyMatrixPainter(dataPoints),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputPage()),
          );
          if (result != null) {
            addDataPoint(result[0], result[1], result[2]);
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataListPage(dataPoints)),
            );
          },
        ),
      ),
    );
  }
}
class HotCrazyMatrixPainter extends CustomPainter {
  final List<DataPoint> dataPoints;

  HotCrazyMatrixPainter(this.dataPoints);

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

    // Draw points
    for (var point in dataPoints) {
      double x = marginLeft + (graphWidth / 10) * point.x;
      double y = graphHeight - ((graphHeight / 6) * (point.y - 4));
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.blue);
    }

    // Draw scales
    _drawScales(canvas, width, height, marginLeft, marginBottom, graphWidth, graphHeight);
  }

  void _drawScales(Canvas canvas, double width, double height, double marginLeft, double marginBottom, double graphWidth, double graphHeight) {
    final double stepX = graphWidth / 10;
    final double stepY = graphHeight / 6;
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

    // Draw axis labels
    _drawText(canvas, "Hotness", marginLeft + (graphWidth / 2) - 20, height - marginBottom + labelOffset + 20, scaleFontSize);
    _drawText(canvas, "Craziness", 5, height - marginBottom - ((10 - 4) * stepY) - 30, scaleFontSize);
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class InputPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController xController = TextEditingController();
  final TextEditingController yController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Input Values")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: xController,
              decoration: InputDecoration(labelText: "Hotness (0-10)"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Nur Ziffern erlauben
              ],
            ),
            TextField(
              controller: yController,
              decoration: InputDecoration(labelText: "Craziness (4-10)"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Nur Ziffern erlauben
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text;
                final double x = double.tryParse(xController.text) ?? 0;
                final double y = double.tryParse(yController.text) ?? 0;
                Navigator.pop(context, [name, x, y]);
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

class DataListPage extends StatelessWidget {
  final List<DataPoint> dataPoints;

  DataListPage(this.dataPoints);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data List")),
      body: ListView.builder(
        itemCount: dataPoints.length,
        itemBuilder: (context, index) {
          final point = dataPoints[index];
          return ListTile(
            title: Text(point.name),
            subtitle: Text("Hotness: ${point.x}, Craziness: ${point.y}"),
          );
        },
      ),
    );
  }
}