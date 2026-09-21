import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17211F),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF24433D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.bluetooth_rounded, color: Color(0xFF9DE3D2)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Knee brace · Left', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('BRACE-04A2  ·  Connected', style: TextStyle(color: Color(0xFFA5B7B2), fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(color: Color(0xFF65D5A6), shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}