import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ClockView extends StatefulWidget {
  final double size;
  const ClockView({Key? key, required this.size}) : super(key: key);

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Transform.rotate(
          angle: -pi / 2,
          child: CustomPaint(
            painter: ClockPainter(),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  var now = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {
    // Math
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var r = min(centerX, centerY);

    // define brushes
    var fillBrush = Paint()..color = const Color(0xFF444974);
    var dotBrush = Paint()..color = const Color(0xFFEAECFF);
    var outlineBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 60;

    var secHandBrush = Paint()
      ..color = Colors.orange.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 60
      ..strokeCap = StrokeCap.round;
    var minHandBrush = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Colors.blue],
      ).createShader(
        Rect.fromCircle(center: center, radius: r),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 30
      ..strokeCap = StrokeCap.round;
    var hourHandBrush = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.amber, Colors.yellow],
      ).createShader(
        Rect.fromCircle(center: center, radius: r),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 24
      ..strokeCap = StrokeCap.round;
    var dashBrush = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    var segmentBrush = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;

    // drawing clock and hands
    canvas.drawCircle(center, r * 0.75, fillBrush);
    canvas.drawCircle(center, r * 0.75, outlineBrush);

    var hourHandX =
        centerX + r * 0.4 * cos((now.hour * 30 + now.minute * 0.5) * pi / 180);
    var hourHandY =
        centerY + r * 0.4 * sin((now.hour * 30 + now.minute * 0.5) * pi / 180);
    var hourHandOffset = Offset(hourHandX, hourHandY);
    canvas.drawLine(center, hourHandOffset, hourHandBrush);
    var minHandX = centerX + r * 0.6 * cos(now.minute * 6 * pi / 180);
    var minHandY = centerY + r * 0.6 * sin(now.minute * 6 * pi / 180);
    var minHandOffset = Offset(minHandX, minHandY);
    canvas.drawLine(center, minHandOffset, minHandBrush);
    var secHandX = centerX + r * 0.6 * cos(now.second * 6 * pi / 180);
    var secHandY = centerY + r * 0.6 * sin(now.second * 6 * pi / 180);
    var secHandOffset = Offset(secHandX, secHandY);
    canvas.drawLine(center, secHandOffset, secHandBrush);

    canvas.drawCircle(center, r / 9, dotBrush);

    // drawing numbers and ticks
    var outerCircleRadius = r;
    var innerCircleRadius = r * 0.9;
    for (double i = 0; i < 360; i += 30) {
      var x1 = centerX + outerCircleRadius * cos(i * pi / 180);
      var y1 = centerY + outerCircleRadius * sin(i * pi / 180);

      var x2 = centerX + innerCircleRadius * cos(i * pi / 180);
      var y2 = centerY + innerCircleRadius * sin(i * pi / 180);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }

    // draw highlights
    var startHour1 = 1 + DateTime.now().timeZoneOffset.inHours;
    var startHour2 = 18 + DateTime.now().timeZoneOffset.inHours;
    var duration = 2;
    var startAngle1 = startHour1 * 30 * pi / 180;
    var startAngle2 = startHour2 * 30 * pi / 180;
    var sweepAngle = duration * 30 * pi / 180;
    var scale = 1.8;
    var rect = Rect.fromCenter(
      center: center,
      width: r * scale,
      height: r * scale,
    );
    canvas.drawArc(rect, startAngle1, sweepAngle, false, segmentBrush);
    canvas.drawArc(rect, startAngle2, sweepAngle, false, segmentBrush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
