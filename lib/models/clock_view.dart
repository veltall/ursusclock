import 'dart:async';
import 'dart:math';
import 'package:ursusclock/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClockView extends ConsumerStatefulWidget {
  final double size;
  const ClockView({Key? key, required this.size}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClockViewState();
}

class _ClockViewState extends ConsumerState<ClockView> {
  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int waitMS = ref.watch(waitDurationProvider).inMicroseconds;
    double waitTime = (waitMS / (3.6 * pow(10, 9)) * 100).round() / 100.0;
    bool active = (waitTime < 0) ? true : false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Transform.rotate(
              angle: -pi / 2,
              child: CustomPaint(
                painter: ClockPainter(ref),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.place, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              active ? "In progress" : waitTime.toString() + " hours",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "avenir",
              ),
            ),
          ],
        ),
        CustomPaint(
          painter: ThinLinePainter(active),
        ),
      ],
    );
  }
}

class ThinLinePainter extends CustomPainter {
  final bool _isActive;
  ThinLinePainter(this._isActive);

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var hintBrush = Paint()
      ..color = const Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width;
    var segmentBrush = Paint()
      ..color = _isActive ? Colors.green : Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawLine(const Offset(160, 0), center, hintBrush);
    canvas.drawLine(const Offset(160, 0), const Offset(220, 0), segmentBrush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ClockPainter extends CustomPainter {
  var now = DateTime.now();
  WidgetRef ref;
  ClockPainter(this.ref);

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

    // =======================================
    // draw ursus features
    now = Utilities.modifyDateTime(now, hour: ref.watch(hourProvider));
    var nowUTC = now.toUtc();
    var session1 = Utilities.roundToHour(nowUTC, hour: 1).toLocal();
    var session2 = Utilities.roundToHour(nowUTC, hour: 18).toLocal();
    var session3 = Utilities.roundToHour(nowUTC, hour: 25).toLocal();
    var sessionDuration = const Duration(hours: 2);

    // preparing brushes
    var activeSegmentBrush = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;
    var futureSegmentBrush = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;
    var timeTilSegmentBrush = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 120;

    // draw highlights
    var startAngle1 = session1.hour * 30 * pi / 180;
    var startAngle2 = session2.hour * 30 * pi / 180;
    var startAngle3 = session3.hour * 30 * pi / 180;
    var timeTillAngle = ((now.hour * 30 + now.minute * 0.5) * pi / 180);
    var sweepAngle = sessionDuration.inHours * 30 * pi / 180;
    var s = 1.7;
    var rect1 = Rect.fromCenter(center: center, width: r * s, height: r * s);
    var rect2 = Rect.fromCenter(center: center, width: r * 2, height: r * 2);

    if (now.isBefore(session1)) {
      canvas.drawArc(rect1, startAngle1, sweepAngle, false, futureSegmentBrush);
      var angleToSession1 = startAngle1 - timeTillAngle;
      canvas.drawArc(
          rect1, timeTillAngle, angleToSession1, false, timeTilSegmentBrush);
    }
    if (!now.isBefore(session1) &&
        !now.isAfter(session1.add(sessionDuration))) {
      canvas.drawArc(rect1, startAngle1, sweepAngle, false, activeSegmentBrush);
    }
    if (now.isAfter(session1.add(sessionDuration)) && now.isBefore(session2)) {
      var rect = session2.difference(now).inSeconds > 43299 ? rect2 : rect1;
      var angleToSession2 = startAngle2 - timeTillAngle;
      if (session2.difference(now).inSeconds > 43299) {
        angleToSession2 += 2 * pi;
      }
      canvas.drawArc(
          rect1, timeTillAngle, angleToSession2, false, timeTilSegmentBrush);
      canvas.drawArc(rect, startAngle2, sweepAngle, false, futureSegmentBrush);
    }
    if (!now.isBefore(session2) &&
        !now.isAfter(session2.add(sessionDuration))) {
      canvas.drawArc(rect1, startAngle2, sweepAngle, false, activeSegmentBrush);
    }
    if (now.isAfter(session2.add(sessionDuration)) &&
        now.isBefore(session3) &&
        session3.difference(now).inHours < 19) {
      var angleToSession3 = startAngle3 - timeTillAngle;
      canvas.drawArc(
          rect1, timeTillAngle, angleToSession3, false, timeTilSegmentBrush);
      canvas.drawArc(rect1, startAngle3, sweepAngle, false, futureSegmentBrush);
    }
    if (!now.isBefore(session3) &&
        !now.isAfter(session3.add(sessionDuration))) {
      canvas.drawArc(rect1, startAngle3, sweepAngle, false, activeSegmentBrush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

var waitDurationProvider = StateProvider((ref) {
  var now =
      Utilities.modifyDateTime(DateTime.now(), hour: ref.watch(hourProvider));
  var nowUTC = now.toUtc();
  var session1 = Utilities.roundToHour(nowUTC, hour: 1).toLocal();
  var session2 = Utilities.roundToHour(nowUTC, hour: 18).toLocal();
  var session3 = Utilities.roundToHour(nowUTC, hour: 25).toLocal();
  var sessionDuration = const Duration(hours: 2);

  var waitDuration = const Duration(minutes: -1);

  if (now.isBefore(session1)) {
    waitDuration = session1.difference(now);
  }
  if (now.isAfter(session1.add(sessionDuration)) && now.isBefore(session2)) {
    waitDuration = session2.difference(now);
  }
  if (now.isAfter(session2.add(sessionDuration)) && now.isBefore(session3)) {
    waitDuration = session3.difference(now);
  }
  return waitDuration;
});
var hourProvider = StateProvider((ref) {
  return DateTime.now().hour;
});
var datetimeProvider = StateProvider((ref) {
  return DateTime.now();
});
