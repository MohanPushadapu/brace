class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.startedAt,
    required this.duration,
  });

  final String id;
  final DateTime startedAt;
  final Duration duration;
}

class SensorReading {
  const SensorReading({
    required this.recordedAt,
    required this.metric,
    required this.value,
    required this.unit,
  });

  final DateTime recordedAt;
  final String metric;
  final double value;
  final String unit;
}
