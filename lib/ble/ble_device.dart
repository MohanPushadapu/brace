class BleDevice {
  const BleDevice({
    required this.id,
    required this.name,
    this.isConnected = false,
    this.rssi,
    this.serviceIds = const [],
  });

  final String id;
  final String name;
  final bool isConnected;
  final int? rssi;
  final List<String> serviceIds;

  BleDevice copyWith({
    String? id,
    String? name,
    bool? isConnected,
    int? rssi,
    List<String>? serviceIds,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
      serviceIds: serviceIds ?? this.serviceIds,
    );
  }
}
