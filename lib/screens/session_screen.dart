import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> with SingleTickerProviderStateMixin {
  final List<double> _samples = [];
  final List<double> _roms = [];
  Timer? _timer;
  double _angle = 42;
  double _repMin = 42;
  double _repMax = 42;
  int _reps = 0;
  int _tick = 0;
  bool _connected = true;
  late final AnimationController _gauge = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  @override
  void initState() {
    super.initState();
  }

  void _addSample() {
    if (!mounted || !_connected) return;
    final phase = (_tick % 30) / 30;
    final value = 8 + (math.sin(phase * math.pi) * 102);
    _tick++;
    if (value < _repMin) _repMin = value;
    if (value > _repMax) _repMax = value;
    if (phase > .96) {
      _reps++;
      _roms.add(_repMax - _repMin);
      _repMin = value;
      _repMax = value;
    }
    setState(() {
      _angle = value;
      _samples.add(value);
      if (_samples.length > 240) _samples.removeAt(0);
    });
    _gauge.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gauge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double averageRom = _roms.isEmpty ? 0 : _roms.reduce((a, b) => a + b) / _roms.length;
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Live session', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _connected ? const Color(0xFFD8EEE7) : const Color(0xFFF7E2DB), borderRadius: BorderRadius.circular(30)), child: Text(_connected ? 'RECORDING' : 'DISCONNECTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _connected ? const Color(0xFF0E7C72) : const Color(0xFFE05D43)))),
      ]),
      const SizedBox(height: 6),
      const Text('DEMO·UNIT  ·  Knee mobility · Left side', style: TextStyle(color: Color(0xFF6D7C77))),
      const SizedBox(height: 20),
      Container(height: 240, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF17211F), borderRadius: BorderRadius.circular(24)), child: Column(children: [const Align(alignment: Alignment.centerLeft, child: Text('CURRENT ANGLE', style: TextStyle(color: Color(0xFFA5B7B2), fontSize: 11, letterSpacing: 1.3))), Expanded(child: AnimatedBuilder(animation: _gauge, builder: (_, __) => CustomPaint(size: Size.infinite, painter: _GaugePainter(angle: _angle, pulse: _gauge.value)))), Text('${_angle.round()}°', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800))])),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _MetricCard(label: 'Reps completed', value: '$_reps')), const SizedBox(width: 10), Expanded(child: _MetricCard(label: 'ROM · current rep', value: '${(_repMax - _repMin).round()}°'))]),
      const SizedBox(height: 22),
      _heading('ROM over reps', averageRom == 0 ? 'Waiting for first rep' : 'Average ${averageRom.round()}°'),
      _panel(CustomPaint(size: const Size(double.infinity, 130), painter: _BarPainter(values: _roms, average: averageRom))),
      const SizedBox(height: 20),
      _heading('Angle trace', 'Last ${_samples.length} samples'),
      _panel(CustomPaint(size: const Size(double.infinity, 140), painter: _TracePainter(values: _samples))),
      const SizedBox(height: 20),
      _heading('Last packet', '5-byte layout'),
      _panel(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Length  5 bytes', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 8), Text('05 32 00 01 7F', style: TextStyle(fontFamily: 'monospace', letterSpacing: 1.2)), SizedBox(height: 8), Text('Packet format matches angle + reps layout.', style: TextStyle(fontSize: 12, color: Color(0xFF0E7C72)))])),
      const SizedBox(height: 20),
      Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => _connected = false), icon: const Icon(Icons.bluetooth_disabled_rounded), label: const Text('Disconnect'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: () => setState(() => _connected = false), icon: const Icon(Icons.stop_rounded), label: const Text('End session'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE05D43), padding: const EdgeInsets.symmetric(vertical: 15))))]),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: const Text('Export session CSV'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14))),
    ]));
  }

  Widget _heading(String title, String detail) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text(detail, style: const TextStyle(fontSize: 12, color: Color(0xFF0E7C72), fontWeight: FontWeight.w700))]);
  Widget _panel(Widget child) => Container(height: 158, margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: child);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label; final String value;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6D7C77))), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800))]));
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.angle, required this.pulse});
  final double angle; final double pulse;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8); final radius = math.min(size.width, size.height) * .34;
    final track = Paint()..color = const Color(0xFF38504A)..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round;
    final active = Paint()..color = const Color(0xFF71D4B7)..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * .8, math.pi * 1.4, false, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * .8, math.pi * 1.4 * (angle / 120).clamp(0, 1), false, active);
  }
  @override bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.angle != angle || oldDelegate.pulse != pulse;
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.values, required this.average});
  final List<double> values; final double average;
  @override
  void paint(Canvas canvas, Size size) { final paint = Paint()..color = const Color(0xFF0E7C72); final maxValue = math.max(1, values.fold<double>(0, math.max)); for (var i = 0; i < values.length; i++) { final h = values[i] / maxValue * (size.height - 20); canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(i * (size.width / math.max(values.length, 8)), size.height - h, size.width / math.max(values.length, 8) - 5, h), const Radius.circular(4)), paint); } final avgY = size.height - (average / maxValue * (size.height - 20)); canvas.drawLine(Offset(0, avgY), Offset(size.width, avgY), Paint()..color = const Color(0xFFE05D43)..strokeWidth = 1.5); }
  @override bool shouldRepaint(covariant _BarPainter oldDelegate) => oldDelegate.values.length != values.length || oldDelegate.average != average;
}

class _TracePainter extends CustomPainter {
  const _TracePainter({required this.values});
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) { if (values.length < 2) return; final path = Path(); for (var i = 0; i < values.length; i++) { final x = i / (values.length - 1) * size.width; final y = size.height - (values[i] / 120 * size.height); if (i == 0) path.moveTo(x, y); else path.lineTo(x, y); } canvas.drawPath(path, Paint()..color = const Color(0xFF0E7C72)..style = PaintingStyle.stroke..strokeWidth = 2.5); }
  @override bool shouldRepaint(covariant _TracePainter oldDelegate) => oldDelegate.values.length != values.length;
}