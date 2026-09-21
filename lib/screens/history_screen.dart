import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      Text('History', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Your recovery, one session at a time', style: TextStyle(color: Color(0xFF6D7C77))),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF0E7C72), borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SEPTEMBER 2026', style: TextStyle(color: Color(0xFFB3E5D9), fontSize: 11, letterSpacing: 1.3)),
        SizedBox(height: 10),
        Row(children: [Expanded(child: _Summary(value: '12', label: 'sessions')), Expanded(child: _Summary(value: '4h 26m', label: 'total time')), Expanded(child: _Summary(value: '+18°', label: 'progress'))]),
      ])),
      const SizedBox(height: 26),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recent sessions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded))]),
      const SizedBox(height: 8),
      const _HistoryItem(day: 'Today', time: '9:42 AM', duration: '18 min', range: '86°', note: 'Good control'),
      const _HistoryItem(day: 'Yesterday', time: '4:15 PM', duration: '22 min', range: '82°', note: 'Steady'),
      const _HistoryItem(day: 'Sep 19', time: '10:08 AM', duration: '16 min', range: '78°', note: 'Building strength'),
    ]));
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.value, required this.label});
  final String value; final String label;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Color(0xFFB3E5D9), fontSize: 11))]);
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.day, required this.time, required this.duration, required this.range, required this.note});
  final String day; final String time; final String duration; final String range; final String note;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFEAF5F1), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.check_rounded, color: Color(0xFF0E7C72))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(day, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('$time  ·  $duration', style: const TextStyle(fontSize: 12, color: Color(0xFF84918D)))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(range, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(note, style: const TextStyle(fontSize: 11, color: Color(0xFF0E7C72)))]) ]));
}