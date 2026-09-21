import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  const SensorChart({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 110 : 180,
      child: CustomPaint(
        painter: _ChartPainter(compact: compact),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('8 AM', style: TextStyle(fontSize: 11, color: Color(0xFF84918D))),
              Text('10 AM', style: TextStyle(fontSize: 11, color: Color(0xFF84918D))),
              Text('12 PM', style: TextStyle(fontSize: 11, color: Color(0xFF84918D))),
              Text('2 PM', style: TextStyle(fontSize: 11, color: Color(0xFF84918D))),
              Text('Now', style: TextStyle(fontSize: 11, color: Color(0xFF0E7C72), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.compact});

  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 24;
    final left = 2.0;
    final right = size.width - 2;
    final points = [
      Offset(left, chartHeight * .69),
      Offset(size.width * .16, chartHeight * .61),
      Offset(size.width * .3, chartHeight * .67),
      Offset(size.width * .44, chartHeight * .35),
      Offset(size.width * .58, chartHeight * .48),
      Offset(size.width * .72, chartHeight * .27),
      Offset(size.width * .84, chartHeight * .39),
      Offset(right, chartHeight * .16),
    ];
    final gridPaint = Paint()..color = const Color(0xFFE2E8E3)..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = chartHeight * index / 3;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      line.lineTo(points[index].dx, points[index].dy);
    }
    final fill = Path.from(line)
      ..lineTo(right, chartHeight)
      ..lineTo(left, chartHeight)
      ..close();
    canvas.drawPath(fill, Paint()..color = const Color(0xFF0E7C72).withValues(alpha: .08));
    canvas.drawPath(line, Paint()
      ..color = const Color(0xFF0E7C72)
      ..strokeWidth = compact ? 2 : 2.5
      ..style = PaintingStyle.stroke);
    for (final point in points) {
      canvas.drawCircle(point, compact ? 2.5 : 3.5, Paint()..color = const Color(0xFFF5F7F3));
      canvas.drawCircle(point, compact ? 1.5 : 2, Paint()..color = const Color(0xFF0E7C72));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}