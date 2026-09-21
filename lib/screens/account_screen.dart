import 'package:flutter/material.dart';

import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.isPhysician = false});

  final bool isPhysician;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? _code;

  void _signOut() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      Text('Account', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(widget.isPhysician ? 'Your physician workspace' : 'Your recovery profile', style: const TextStyle(color: Color(0xFF6D7C77))),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [
        const CircleAvatar(radius: 26, backgroundColor: Color(0xFFD8EEE7), child: Icon(Icons.person_rounded, color: Color(0xFF0E7C72))),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Alex Morgan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Patient ID  AX7KQ2', style: TextStyle(color: Color(0xFF6D7C77)))])),
      ])),
      const SizedBox(height: 18),
      if (!widget.isPhysician) ...[
        Text('One-time physician link', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Share a single-use code that expires in 24 hours.', style: TextStyle(color: Color(0xFF6D7C77))),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF17211F), borderRadius: BorderRadius.circular(20)), child: Column(children: [
          Text(_code ?? '•••• ••••', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 4)),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: () => setState(() => _code = 'K7M2QX9A'), icon: const Icon(Icons.qr_code_2_rounded), label: Text(_code == null ? 'Generate code + QR' : 'Regenerate code'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white)),
        ])),
      ],
      const SizedBox(height: 26),
      Text('Linked accounts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Material(color: Colors.transparent, child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: const CircleAvatar(backgroundColor: Color(0xFFEAF5F1), child: Icon(Icons.medical_services_outlined, color: Color(0xFF0E7C72))), title: const Text('Dr. Chen'), subtitle: const Text('Linked account'), trailing: TextButton(onPressed: () {}, child: const Text('Unlink')))),
      const SizedBox(height: 18),
      OutlinedButton.icon(onPressed: _signOut, icon: const Icon(Icons.logout_rounded), label: const Text('Sign out'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE05D43), padding: const EdgeInsets.symmetric(vertical: 15))),
    ]));
  }
}