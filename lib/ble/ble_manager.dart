import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_device.dart';

class BleManager {
  Future<List<BleDevice>> scan({
    String namePrefix = '',
    Iterable<String> serviceIds = const [],
    bool onlyMatchingServices = false,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    await _waitForBluetoothOn();
    final normalizedServices = serviceIds.map(_normalizeUuid).where((id) => id.isNotEmpty).toSet();
    final results = <String, BleDevice>{};
    final subscription = FlutterBluePlus.scanResults.listen((scanResults) {
      for (final result in scanResults) {
        final device = result.device;
        final name = device.platformName.isNotEmpty ? device.platformName : result.advertisementData.advName;
        final advertisedServices = result.advertisementData.serviceUuids.map((uuid) => _normalizeUuid(uuid.str)).toList();
        final matchesName = namePrefix.trim().isEmpty || name.toLowerCase().startsWith(namePrefix.trim().toLowerCase());
        final matchesService = normalizedServices.isEmpty || advertisedServices.any(normalizedServices.contains);
        if (!matchesName || (onlyMatchingServices && !matchesService)) continue;
        results[device.remoteId.str] = BleDevice(id: device.remoteId.str, name: name.isEmpty ? 'Unnamed device' : name, rssi: result.rssi, serviceIds: advertisedServices);
      }
    });

    try {
      // Scan broadly first. iOS filters out devices that do not advertise every native
      // withServices UUID, while many peripherals expose their service after connecting.
      await _startScan(timeout);
        await FlutterBluePlus.isScanning
          .where((scanning) => !scanning)
          .first
          .timeout(timeout + const Duration(seconds: 2));
      return results.values.toList();
    } finally {
      await subscription.cancel();
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    }
  }

  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
  }

  Future<void> _waitForBluetoothOn() async {
    try {
      var state = await FlutterBluePlus.adapterState.first.timeout(const Duration(seconds: 10));
      _throwIfBluetoothUnavailable(state);
      if (state == BluetoothAdapterState.on) return;
      state = await FlutterBluePlus.adapterState.firstWhere((nextState) {
        _throwIfBluetoothUnavailable(nextState);
        return nextState == BluetoothAdapterState.on;
      }).timeout(const Duration(seconds: 10));
      if (state == BluetoothAdapterState.on) return;
    } on TimeoutException {
      throw StateError('Bluetooth did not become ready. Open Settings > Privacy & Security > Bluetooth, allow Brace Yourself, then try again.');
    }
  }

  Future<void> _startScan(Duration timeout) {
    return FlutterBluePlus.startScan(withServices: const [], timeout: timeout);
  }

  void _throwIfBluetoothUnavailable(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.off:
        throw StateError('Bluetooth is turned off. Turn it on in Settings and try again.');
      case BluetoothAdapterState.unauthorized:
        throw StateError('Bluetooth access is denied. Open Settings > Privacy & Security > Bluetooth and allow Brace Yourself.');
      case BluetoothAdapterState.unavailable:
        throw StateError('Bluetooth is unavailable on this device.');
      default:
        return;
    }
  }

  Future<BleConnectionDetails> connect(BleDevice device, {Duration timeout = const Duration(seconds: 15), void Function(String status)? onStatus}) async {
    final bluetoothDevice = BluetoothDevice.fromId(device.id);
    onStatus?.call('Connecting to device...');
    if (!bluetoothDevice.isConnected) {
      await bluetoothDevice.connect(license: License.nonprofit, timeout: timeout);
    }
    try {
      onStatus?.call('Connected. Discovering services...');
      final services = await bluetoothDevice.discoverServices(timeout: timeout.inSeconds);
      return BleConnectionDetails(device: device.copyWith(isConnected: true), services: services);
    } catch (_) {
      await bluetoothDevice.disconnect();
      rethrow;
    }
  }

  Future<void> disconnect(BleDevice device) async {
    await BluetoothDevice.fromId(device.id).disconnect();
  }

  String _normalizeUuid(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.length == 4) return '0000$normalized-0000-1000-8000-00805f9b34fb';
    if (normalized.length == 8) return '$normalized-0000-1000-8000-00805f9b34fb';
    return normalized;
  }
}

class BleConnectionDetails {
  const BleConnectionDetails({required this.device, required this.services});

  final BleDevice device;
  final List<BluetoothService> services;
}
