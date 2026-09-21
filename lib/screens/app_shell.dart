import 'package:flutter/material.dart';

import 'device_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'session_screen.dart';
import 'account_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.isPhysician = false});

  final bool isPhysician;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    DeviceScreen(),
    SessionScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: [..._screens, AccountScreen(isPhysician: widget.isPhysician)]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD8EEE7),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.bluetooth_rounded), label: 'Devices'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline_rounded), label: 'Session'),
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Account'),
        ],
      ),
    );
  }
}