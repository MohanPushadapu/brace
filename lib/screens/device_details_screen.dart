import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/ble_manager.dart';

enum _ReadFormat { hex, decimal, ascii, binary }

class DeviceDetailsScreen extends StatefulWidget {
  const DeviceDetailsScreen({super.key, required this.details, this.onDisconnected});

  final BleConnectionDetails details;
  final VoidCallback? onDisconnected;

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final _events = <String>[];
  final _subscriptions = <StreamSubscription<List<int>>>[];
  final _subscriptionByCharacteristic = <String, StreamSubscription<List<int>>>{};
  final _manager = BleManager();
  bool _disconnected = false;
  _ReadFormat _readFormat = _ReadFormat.hex;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    if (!_disconnected) unawaited(_manager.disconnect(widget.details.device));
    super.dispose();
  }

  Future<void> _disconnect() async {
    if (_disconnected) return;
    await _manager.disconnect(widget.details.device);
    _disconnected = true;
    widget.onDisconnected?.call();
    if (mounted) Navigator.of(context).pop();
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() => _events.insert(0, message));
  }

  Future<void> _read(BluetoothCharacteristic characteristic) async {
    try {
      final value = await characteristic.read();
      _log('${characteristic.uuid.str} read (${_readFormatLabel}): ${_format(value)}');
    } catch (error) {
      _log('${characteristic.uuid.str} read failed: $error');
    }
  }

  Future<void> _write(BluetoothCharacteristic characteristic, String input) async {
    try {
      final bytes = input.trim().split(RegExp(r'[ ,]+')).where((part) => part.isNotEmpty).map((part) => int.parse(part, radix: 16)).toList();
      await characteristic.write(bytes, withoutResponse: characteristic.properties.writeWithoutResponse && !characteristic.properties.write);
      _log('${characteristic.uuid.str} wrote: ${_hex(bytes)}');
    } catch (error) {
      _log('${characteristic.uuid.str} write failed: $error');
    }
  }

  Future<void> _toggleSubscription(BluetoothCharacteristic characteristic, bool enabled) async {
    final key = characteristic.uuid.str;
    try {
      await characteristic.setNotifyValue(enabled);
      if (enabled) {
        final subscription = characteristic.onValueReceived.listen((value) => _log('${characteristic.uuid.str} notify (${_readFormatLabel}): ${_format(value)}'));
        _subscriptionByCharacteristic[key] = subscription;
        _subscriptions.add(subscription);
        _log('Subscribed to ${characteristic.uuid.str}.');
      } else {
        await _subscriptionByCharacteristic.remove(key)?.cancel();
        _log('Unsubscribed from ${characteristic.uuid.str}.');
      }
    } catch (error) {
      _log('${characteristic.uuid.str} subscribe failed: $error');
    }
  }

  String get _readFormatLabel => switch (_readFormat) {
        _ReadFormat.hex => 'HEX',
        _ReadFormat.decimal => 'DEC',
        _ReadFormat.ascii => 'ASCII',
        _ReadFormat.binary => 'BIN',
      };

  String _hex(List<int> bytes) => bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');

  String _format(List<int> bytes) => switch (_readFormat) {
        _ReadFormat.hex => bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' '),
        _ReadFormat.decimal => bytes.join(' '),
        _ReadFormat.ascii => String.fromCharCodes(bytes.map((byte) => byte >= 32 && byte <= 126 ? byte : 0x2E)),
        _ReadFormat.binary => bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join(' '),
      };

  @override
  Widget build(BuildContext context) {
    final device = widget.details.device;
    return Scaffold(
      appBar: AppBar(title: const Text('Device details'), actions: [IconButton(onPressed: _disconnect, tooltip: 'Disconnect', icon: const Icon(Icons.bluetooth_disabled_rounded))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
        Text(device.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        SelectableText(device.id, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF6D7C77))),
        const SizedBox(height: 20),
        _Panel(child: Row(children: [
          const Expanded(child: Text('Read format', style: TextStyle(fontWeight: FontWeight.w700))),
          DropdownButton<_ReadFormat>(value: _readFormat, onChanged: (format) { if (format != null) setState(() => _readFormat = format); }, items: const [DropdownMenuItem(value: _ReadFormat.hex, child: Text('HEX')), DropdownMenuItem(value: _ReadFormat.decimal, child: Text('Decimal')), DropdownMenuItem(value: _ReadFormat.ascii, child: Text('ASCII')), DropdownMenuItem(value: _ReadFormat.binary, child: Text('Binary'))]),
        ])),
        const SizedBox(height: 12),
        _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (widget.details.services.isEmpty) const Text('No services were reported.', style: TextStyle(color: Color(0xFF6D7C77))) else ...widget.details.services.map((service) => _ServiceSection(service: service, onRead: _read, onWrite: _write, onToggleSubscription: _toggleSubscription)),
        ])),
        const SizedBox(height: 18),
        if (_events.isNotEmpty) _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8), ..._events.take(20).map((event) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(event, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))))])),
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: _disconnect, icon: const Icon(Icons.bluetooth_disabled_rounded), label: const Text('Disconnect'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE05D43), padding: const EdgeInsets.symmetric(vertical: 14))),
      ]),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  const _ServiceSection({required this.service, required this.onRead, required this.onWrite, required this.onToggleSubscription});

  final BluetoothService service;
  final Future<void> Function(BluetoothCharacteristic) onRead;
  final Future<void> Function(BluetoothCharacteristic, String) onWrite;
  final Future<void> Function(BluetoothCharacteristic, bool enabled) onToggleSubscription;

  @override
  Widget build(BuildContext context) => ExpansionTile(title: Text(service.uuid.str, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)), subtitle: Text('${service.characteristics.length} characteristic(s)'), children: service.characteristics.map((characteristic) => _CharacteristicTile(characteristic: characteristic, onRead: onRead, onWrite: onWrite, onToggleSubscription: onToggleSubscription)).toList());
}

class _CharacteristicTile extends StatefulWidget {
  const _CharacteristicTile({required this.characteristic, required this.onRead, required this.onWrite, required this.onToggleSubscription});

  final BluetoothCharacteristic characteristic;
  final Future<void> Function(BluetoothCharacteristic) onRead;
  final Future<void> Function(BluetoothCharacteristic, String) onWrite;
  final Future<void> Function(BluetoothCharacteristic, bool enabled) onToggleSubscription;

  @override
  State<_CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<_CharacteristicTile> {
  final _writeController = TextEditingController();
  bool _subscribed = false;

  @override
  void dispose() {
    _writeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final properties = widget.characteristic.properties;
    final actions = <Widget>[];
    if (properties.read) actions.add(IconButton(onPressed: () => widget.onRead(widget.characteristic), tooltip: 'Read', icon: const Icon(Icons.download_rounded)));
    if (properties.notify || properties.indicate) actions.add(IconButton(onPressed: () async { await widget.onToggleSubscription(widget.characteristic, !_subscribed); if (mounted) setState(() => _subscribed = !_subscribed); }, tooltip: _subscribed ? 'Unsubscribe' : 'Subscribe', icon: Icon(_subscribed ? Icons.notifications_active : Icons.notifications_none_outlined, color: _subscribed ? const Color(0xFF0E7C72) : null)));
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(widget.characteristic.uuid.str, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))), ...actions]),
      Text(_properties(properties), style: const TextStyle(fontSize: 11, color: Color(0xFF0E7C72))),
      if (properties.write || properties.writeWithoutResponse) ...[
        const SizedBox(height: 8),
        Row(children: [Expanded(child: TextField(controller: _writeController, decoration: const InputDecoration(labelText: 'Hex bytes', hintText: '05 32 00 01 7F', isDense: true, border: OutlineInputBorder()))), const SizedBox(width: 8), IconButton(onPressed: () => widget.onWrite(widget.characteristic, _writeController.text), tooltip: 'Write', icon: const Icon(Icons.upload_rounded))]),
      ],
    ]));
  }

  String _properties(CharacteristicProperties properties) => [if (properties.read) 'read', if (properties.write) 'write', if (properties.writeWithoutResponse) 'write without response', if (properties.notify) 'notify', if (properties.indicate) 'indicate'].join(' · ');
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: child);
}
