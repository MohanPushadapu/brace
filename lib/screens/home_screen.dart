import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../widgets/device_card.dart';
import '../widgets/sensor_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MONDAY, SEP 21', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.4, color: const Color(0xFF6D7C77))),
                const SizedBox(height: 6),
                Text('Good morning, Alex', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF17211F))),
              ]),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, size: 28)),
            ],
          ),
          const SizedBox(height: 24),
          const DeviceCard(),
          const SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Today\'s progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            TextButton(onPressed: () {}, child: const Text('See details')),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFD8EEE7), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.trending_up_rounded, color: Color(0xFF0E7C72))),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Range of motion', style: TextStyle(fontSize: 13, color: Color(0xFF6D7C77))),
                  SizedBox(height: 3),
                  Text('Improving', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF17211F))),
                ]),
                const Spacer(),
                const Text('+12°', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0E7C72))),
              ]),
              const SizedBox(height: 14),
              const SensorChart(compact: true),
            ]),
          ),
          const SizedBox(height: 26),
          Text('Live readings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...mockSensors.map((sensor) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _SensorTile(sensor: sensor))),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start a session'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF0E7C72))),
        ],
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  const _SensorTile({required this.sensor});

  final SensorData sensor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: sensor.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(sensor.icon, color: sensor.color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sensor.name, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(sensor.status, style: const TextStyle(fontSize: 12, color: Color(0xFF84918D)))])),
        Text(sensor.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(width: 3),
        Text(sensor.unit, style: const TextStyle(fontSize: 12, color: Color(0xFF6D7C77))),
      ]),
    );
  }
}