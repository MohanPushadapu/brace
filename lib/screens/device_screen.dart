import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ble/ble_device.dart';
import '../ble/ble_manager.dart';
import 'device_details_screen.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  static const _favoriteDevicesKey = 'favorite_bluetooth_device_ids';
  final _searchController = TextEditingController();
  final _serviceController = TextEditingController(text: 'FFE0');
  final _bleManager = BleManager();
  final _favoriteIds = <String>{};
  final _connectedIds = <String>{};
  List<BleDevice> _devices = [];
  bool _scanning = false;
  String? _scanError;
  bool _setupOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshList);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    final savedIds = preferences.getStringList(_favoriteDevicesKey) ?? const <String>[];
    if (mounted) setState(() => _favoriteIds.addAll(savedIds));
  }

  @override
  void dispose() {
    _searchController.removeListener(_refreshList);
    _searchController.dispose();
    _serviceController.dispose();
    _bleManager.stopScan();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_scanning) {
      await _bleManager.stopScan();
      if (mounted) setState(() => _scanning = false);
      return;
    }
    setState(() {
      _scanning = true;
      _scanError = null;
    });
    try {
      final devices = await _bleManager.scan(
        serviceIds: _serviceController.text.split(','),
        onlyMatchingServices: false,
      );
      if (mounted) setState(() => _devices = devices);
    } catch (error) {
      if (mounted) setState(() => _scanError = 'Bluetooth scan failed: $error');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void stopScanning() {
    if (!_scanning) return;
    unawaited(_bleManager.stopScan());
    if (mounted) setState(() => _scanning = false);
  }

  void _refreshList() => setState(() {});

  List<BleDevice> get _visibleDevices {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _devices.where((device) {
      return query.isEmpty || device.name.toLowerCase().contains(query) || device.id.toLowerCase().contains(query);
    }).toList();
    filtered.sort((a, b) {
      final favoriteOrder = (_favoriteIds.contains(b.id) ? 1 : 0).compareTo(_favoriteIds.contains(a.id) ? 1 : 0);
      if (favoriteOrder != 0) return favoriteOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return filtered;
  }

  void _toggleFavorite(BleDevice device) {
    setState(() {
      if (!_favoriteIds.add(device.id)) _favoriteIds.remove(device.id);
    });
    SharedPreferences.getInstance().then((preferences) => preferences.setStringList(_favoriteDevicesKey, _favoriteIds.toList()));
  }

  Future<void> _connect(BleDevice device) async {
    final details = await showModalBottomSheet<BleConnectionDetails>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConnectingSheet(device: device, manager: _bleManager, onConnected: () {
        if (mounted) setState(() => _connectedIds.add(device.id));
      }, onDisconnected: () {
        if (mounted) setState(() {
          _connectedIds.remove(device.id);
        });
      }),
    );
    if (details == null || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DeviceDetailsScreen(details: details, onDisconnected: () {
      if (mounted) setState(() => _connectedIds.remove(device.id));
    })));
  }

  @override
  Widget build(BuildContext context) {
    final devices = _visibleDevices;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Text('Devices', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Manage your connected rehabilitation gear', style: TextStyle(color: Color(0xFF6D7C77))),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: TextField(controller: _searchController, decoration: const InputDecoration(hintText: 'Search devices', prefixIcon: Icon(Icons.search_rounded), isDense: true, border: OutlineInputBorder()))),
            const SizedBox(width: 10),
            SizedBox(width: 54, height: 52, child: FilledButton(onPressed: _scan, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0E7C72), padding: EdgeInsets.zero), child: _scanning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.refresh_rounded))),
          ]),
          const SizedBox(height: 8),
          Text(_scanning ? 'Scanning nearby Bluetooth devices...' : '${devices.length} device${devices.length == 1 ? '' : 's'} identified', style: const TextStyle(fontSize: 12, color: Color(0xFF84918D))),
          if (_scanError != null) ...[
            const SizedBox(height: 10),
            _MessagePanel(icon: Icons.error_outline_rounded, message: _scanError!, color: const Color(0xFFE05D43)),
          ],
          const SizedBox(height: 16),
          if (devices.isEmpty && !_scanning)
            const _MessagePanel(icon: Icons.bluetooth_searching_rounded, message: 'No devices yet. Press scan to look for nearby Bluetooth devices.', color: Color(0xFF0E7C72))
          else
            ...devices.map((device) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _DeviceTile(device: device, favorite: _favoriteIds.contains(device.id), connected: _connectedIds.contains(device.id), onFavorite: () => _toggleFavorite(device), onConnect: () => _connect(device)))),
          const SizedBox(height: 18),
          _SetupPanel(open: _setupOpen, serviceController: _serviceController, onToggle: () => setState(() => _setupOpen = !_setupOpen)),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.favorite, required this.connected, required this.onFavorite, required this.onConnect});

  final BleDevice device;
  final bool favorite;
  final bool connected;
  final VoidCallback onFavorite;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: const CircleAvatar(backgroundColor: Color(0xFFEAF5F1), child: Icon(Icons.bluetooth_rounded, color: Color(0xFF0E7C72))),
        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${device.id}  ·  RSSI ${device.rssi ?? '--'}', style: const TextStyle(fontSize: 11, color: Color(0xFF84918D))),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(onPressed: onFavorite, tooltip: favorite ? 'Remove favorite' : 'Favorite device', icon: Icon(favorite ? Icons.star_rounded : Icons.star_border_rounded, color: favorite ? const Color(0xFFE0A642) : const Color(0xFF84918D))),
          IconButton(onPressed: onConnect, tooltip: connected ? 'View connection' : 'Connect', icon: Icon(connected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_rounded, color: connected ? const Color(0xFF0E7C72) : const Color(0xFF6D7C77))),
        ]),
      ),
    );
  }
}

class _ConnectingSheet extends StatefulWidget {
  const _ConnectingSheet({required this.device, required this.manager, required this.onConnected, required this.onDisconnected});

  final BleDevice device;
  final BleManager manager;
  final VoidCallback onConnected;
  final VoidCallback onDisconnected;

  @override
  State<_ConnectingSheet> createState() => _ConnectingSheetState();
}

class _ConnectingSheetState extends State<_ConnectingSheet> {
  String _status = 'Connecting and discovering services...';
  String? _error;
  BleConnectionDetails? _details;

  @override
  void initState() {
    super.initState();
    _connectAndDiscover();
  }

  Future<void> _connectAndDiscover() async {
    try {
      final details = await widget.manager.connect(widget.device, onStatus: (status) {
        if (mounted) setState(() => _status = status);
      });
      if (mounted) {
        widget.onConnected();
        setState(() {
          _details = details;
          _status = 'Connected. Services discovered.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Connection failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.bluetooth_searching_rounded, color: Color(0xFF0E7C72)), const SizedBox(width: 10), Expanded(child: Text(widget.device.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 8),
      Text(_error ?? _status, style: TextStyle(color: _error == null ? const Color(0xFF6D7C77) : const Color(0xFFE05D43))),
      const SizedBox(height: 18),
      if (_error == null && _details == null) const LinearProgressIndicator(),
      if (_details != null) ...[
        const SizedBox(height: 18),
        Text('${_details!.services.length} service${_details!.services.length == 1 ? '' : 's'} found', style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (_details!.services.isEmpty) const Text('The device connected but did not report any services.', style: TextStyle(color: Color(0xFF6D7C77))) else ..._details!.services.map((service) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${service.uuid.str}  ·  ${service.characteristics.length} characteristic${service.characteristics.length == 1 ? '' : 's'}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)))),
        const SizedBox(height: 10),
        Row(children: [
          OutlinedButton.icon(onPressed: () async { await widget.manager.disconnect(widget.device); widget.onDisconnected(); if (mounted) Navigator.of(context).pop(); }, icon: const Icon(Icons.bluetooth_disabled_rounded), label: const Text('Disconnect')),
          const SizedBox(width: 10),
          if (_details != null) FilledButton.icon(onPressed: () => Navigator.of(context).pop(_details), icon: const Icon(Icons.open_in_new_rounded), label: const Text('Device details')),
          if (_details != null) const SizedBox(width: 10),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ]),
      ],
      if (_error != null) ...[
        const SizedBox(height: 14),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))),
      ],
    ])));
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.icon, required this.message, required this.color});

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF6D7C77))))]));
}

class _SetupPanel extends StatelessWidget {
  const _SetupPanel({required this.open, required this.serviceController, required this.onToggle});

  final bool open;
  final TextEditingController serviceController;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [Row(children: [const Icon(Icons.tune_rounded, color: Color(0xFF0E7C72)), const SizedBox(width: 10), const Expanded(child: Text('Scan setup', style: TextStyle(fontWeight: FontWeight.w800))), IconButton(onPressed: onToggle, icon: Icon(open ? Icons.expand_less : Icons.expand_more))]), if (open) ...[const SizedBox(height: 8), TextField(controller: serviceController, decoration: const InputDecoration(labelText: 'Service IDs to probe', hintText: 'FFE0, FFF0, or a full UUID', isDense: true, border: OutlineInputBorder())), const SizedBox(height: 8), const Align(alignment: Alignment.centerLeft, child: Text('Accepts 16-bit, 32-bit, and full 128-bit UUIDs.', style: TextStyle(fontSize: 11, color: Color(0xFF84918D))))]]));
}
