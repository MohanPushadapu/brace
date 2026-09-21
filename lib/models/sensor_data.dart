import 'package:flutter/material.dart';

class SensorData {
  const SensorData({
    required this.name,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
  });

  final String name;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;
}

const mockSensors = [
  SensorData(
    name: 'Knee Range of Motion',
    value: '86',
    unit: '°',
    icon: Icons.accessibility_new_rounded,
    color: Color(0xFFE47A53),
    status: 'On track',
  ),
  SensorData(
    name: 'Session time',
    value: '18',
    unit: 'min',
    icon: Icons.timer_outlined,
    color: Color(0xFF0E7C72),
    status: 'Active today',
  ),
];