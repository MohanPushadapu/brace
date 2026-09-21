import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/ble_device.dart';
import '../ble/ble_manager.dart';

class BleTestScreen extends StatefulWidget {
  const BleTestScreen({super.key});

  @override
  State<BleTestScreen> createState() => _BleTestScreenState();
}

class _BleTestScreenState extends State<BleTestScreen> {
  final _manager = BleManager();
  final _log = <String>[];
  final _subscriptions = <StreamSubscription<List<int>>>[];
  List<BleDevice> _devices = [];
  List<BluetoothService> _services = [];
  BleDevice? _selected;
  bool _scanning = false;
  bool _connecting = false;
  String? _error;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    if (_selected != null) _manager.disconnect(_selected!);
    _manager.stopScan();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _error = null;
      _devices = [];
    });
    try {
      final devices = await _manager.scan(timeout: const Duration(seconds: 6));
      if (mounted) setState(() => _devices = devices);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _connect(BleDevice device) async {
    setState(() {
      _selected = device;
      _connecting = true;
      _error = null;
      _services = [];
      _log.clear();
    });
    try {
      final details = await _manager.connect(device);
      if (mounted) {
        setState(() {
          _selected = details.device;
          _services = details.services;
        });
        _addLog('Connected and discovered ${details.services.length} service(s).');
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Connection failed: $error');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    final device = _selected;
    if (device == null) return;
    await _manager.disconnect(device);
    if (mounted) {
      setState(() {
        _selected = null;
        _services = [];
      });
      _addLog('Disconnected.');
    }
  }

  Future<void> _read(BluetoothCharacteristic characteristic) async {
    try {
      final value = await characteristic.read();
      _addLog('${characteristic.uuid.str} read: ${_hex(value)}');
    } catch (error) {
      _addLog('${characteristic.uuid.str} read failed: $error');
    }
  }

  Future<void> _subscribe(BluetoothCharacteristic characteristic) async {
    try {
      await characteristic.setNotifyValue(true);
      final subscription = characteristic.onValueReceived.listen((value) => _addLog('${characteristic.uuid.str} notify: ${_hex(value)}'));
      _subscriptions.add(subscription);
      _addLog('Subscribed to ${characteristic.uuid.str}.');
    } catch (error) {
      _addLog('${characteristic.uuid.str} subscribe failed: $error');
    }
  }

  void _addLog(String value) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, '${DateTime.now().toIso8601String().substring(11, 19)}  $value');
      if (_log.length > 30) _log.removeLast();
    });
  }

  String _hex(List<int> value) => value.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('BLE test bench', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), IconButton(onPressed: _scan, tooltip: 'Scan again', icon: const Icon(Icons.refresh_rounded))]),
      const Text('Branch-only Bluetooth diagnostics', style: TextStyle(color: Color(0xFF6D7C77))),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: _scanning ? null : _scan, icon: _scanning ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.bluetooth_searching_rounded), label: Text(_scanning ? 'Scanning...' : 'Scan nearby devices'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0E7C72), padding: const EdgeInsets.symmetric(vertical: 15))),
      const SizedBox(height: 14),
      if (_error != null) _TestPanel(child: Text(_error!, style: const TextStyle(color: Color(0xFFE05D43)))),
      Text('${_devices.length} detected device${_devices.length == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      ..._devices.map((device) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(16), child: ListTile(onTap: () => _connect(device), leading: const Icon(Icons.bluetooth_rounded, color: Color(0xFF0E7C72)), title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${device.id}  ·  RSSI ${device.rssi ?? '--'}', style: const TextStyle(fontSize: 11)), trailing: const Icon(Icons.chevron_right_rounded))))),
      if (_connecting) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: LinearProgressIndicator()),
      if (_selected != null && !_connecting) ...[
        const SizedBox(height: 16),
        _TestPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.link_rounded, color: Color(0xFF0E7C72)), const SizedBox(width: 8), Expanded(child: Text(_selected!.name, style: const TextStyle(fontWeight: FontWeight.w800))), TextButton(onPressed: _disconnect, child: const Text('Disconnect'))]),
          const Divider(),
          Text('${_services.length} services discovered', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._services.map((service) => _ServiceTestTile(service: service, onRead: _read, onSubscribe: _subscribe)),
        ])),
      ],
      const SizedBox(height: 16),
      _TestPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Event log', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), if (_log.isEmpty) const Text('Connection, service, and notification events will appear here.', style: TextStyle(color: Color(0xFF6D7C77))) else ..._log.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(entry, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))))])),
    ]));
  }
}

class _ServiceTestTile extends StatelessWidget {
  const _ServiceTestTile({required this.service, required this.onRead, required this.onSubscribe});

  final BluetoothService service;
  final Future<void> Function(BluetoothCharacteristic) onRead;
  final Future<void> Function(BluetoothCharacteristic) onSubscribe;

  @override
  Widget build(BuildContext context) => ExpansionTile(title: Text(service.uuid.str, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)), subtitle: Text('${service.characteristics.length} characteristic(s)'), children: service.characteristics.map((characteristic) => ListTile(contentPadding: const EdgeInsets.only(left: 12), title: Text(characteristic.uuid.str, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)), subtitle: Text(_properties(characteristic.properties)), trailing: Wrap(children: [if (characteristic.properties.read) IconButton(onPressed: () => onRead(characteristic), icon: const Icon(Icons.download_rounded), tooltip: 'Read'), if (characteristic.properties.notify || characteristic.properties.indicate) IconButton(onPressed: () => onSubscribe(characteristic), icon: const Icon(Icons.notifications_active_outlined), tooltip: 'Subscribe')]))).toList());

  String _properties(CharacteristicProperties properties) => [if (properties.read) 'read', if (properties.write) 'write', if (properties.writeWithoutResponse) 'write no response', if (properties.notify) 'notify', if (properties.indicate) 'indicate'].join(' · ');
}

class _TestPanel extends StatelessWidget {
  const _TestPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: child);
}
