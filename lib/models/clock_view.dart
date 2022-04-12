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
    return Center(
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
    );
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

    // draw highlights
    var startAngle1 = session1.hour * 30 * pi / 180;
    var startAngle2 = session2.hour * 30 * pi / 180;
    var startAngle3 = session3.hour * 30 * pi / 180;
    var sweepAngle = sessionDuration.inHours * 30 * pi / 180;
    var scale = 1.7;
    var rect1 = Rect.fromCenter(
      center: center,
      width: r * scale,
      height: r * scale,
    );
    var rect2 = Rect.fromCenter(center: center, width: r * 2, height: r * 2);

    if (now.isBefore(session1)) {
      canvas.drawArc(rect1, startAngle1, sweepAngle, false, futureSegmentBrush);
    }
    if (!now.isBefore(session1) &&
        !now.isAfter(session1.add(sessionDuration))) {
      canvas.drawArc(rect1, startAngle1, sweepAngle, false, activeSegmentBrush);
    }
    if (now.isBefore(session2)) {
      var rect = session2.difference(now).inSeconds > 43299 ? rect2 : rect1;
      canvas.drawArc(rect, startAngle2, sweepAngle, false, futureSegmentBrush);
    }
    if (!now.isBefore(session2) &&
        !now.isAfter(session2.add(sessionDuration))) {
      canvas.drawArc(rect1, startAngle2, sweepAngle, false, activeSegmentBrush);
    }
    if (now.isBefore(session3) && session3.difference(now).inHours < 19) {
      var rect = session3.difference(now).inHours > 9 ? rect2 : rect1;
      canvas.drawArc(rect, startAngle3, sweepAngle, false, futureSegmentBrush);
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

var hourProvider = StateProvider((ref) {
  return DateTime.now().hour;
});
var datetimeProvider = StateProvider((ref) {
  return DateTime.now();
});
