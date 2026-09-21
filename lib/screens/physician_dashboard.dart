import 'package:flutter/material.dart';

class PhysicianDashboard extends StatelessWidget {
  const PhysicianDashboard({super.key});

  static const patients = [
    _PatientStats(name: 'Maya Thompson', initials: 'MT', status: 'Improving', statusColor: Color(0xFF0E7C72), sessions: '8', range: '86°', change: '+12°', lastSeen: 'Today, 9:42 AM'),
    _PatientStats(name: 'Jordan Lee', initials: 'JL', status: 'Needs attention', statusColor: Color(0xFFE47A53), sessions: '5', range: '64°', change: '-3°', lastSeen: 'Yesterday, 4:15 PM'),
    _PatientStats(name: 'Samira Patel', initials: 'SP', status: 'On track', statusColor: Color(0xFF6D7EC7), sessions: '11', range: '92°', change: '+8°', lastSeen: 'Yesterday, 11:08 AM'),
    _PatientStats(name: 'Ethan Brooks', initials: 'EB', status: 'No recent data', statusColor: Color(0xFF84918D), sessions: '3', range: '—', change: '—', lastSeen: 'Sep 17, 2:20 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PHYSICIAN PORTAL', style: TextStyle(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: Color(0xFF0E7C72))),
                const SizedBox(height: 6),
                Text('Good morning, Dr. Chen', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF17211F))),
              ]),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, size: 28)),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _SummaryCard(value: '24', label: 'Active patients', icon: Icons.groups_2_outlined, color: const Color(0xFF0E7C72))),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(value: '18', label: 'This week', icon: Icons.trending_up_rounded, color: const Color(0xFF6D7EC7))),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(value: '3', label: 'Need review', icon: Icons.flag_outlined, color: const Color(0xFFE47A53))),
            ]),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Patient overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
            ]),
            const SizedBox(height: 4),
            const Text('Recent sensor activity across your caseload', style: TextStyle(color: Color(0xFF6D7C77))),
            const SizedBox(height: 14),
            ...patients.map((patient) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _PatientCard(patient: patient))),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.value, required this.label, required this.icon, required this.color});

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 10, 13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF17211F))),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6D7C77))),
      ]),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final _PatientStats patient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            Row(children: [
              CircleAvatar(radius: 22, backgroundColor: patient.statusColor.withValues(alpha: .12), child: Text(patient.initials, style: TextStyle(color: patient.statusColor, fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: patient.statusColor, shape: BoxShape.circle)), const SizedBox(width: 5), Text(patient.status, style: TextStyle(fontSize: 12, color: patient.statusColor, fontWeight: FontWeight.w600))])])),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF84918D)),
            ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Divider(height: 1)),
            Row(children: [Expanded(child: _PatientMetric(label: 'Sessions', value: patient.sessions)), Expanded(child: _PatientMetric(label: 'Flexion', value: patient.range)), Expanded(child: _PatientMetric(label: 'Change', value: patient.change, accent: true))]),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text('Last active  ${patient.lastSeen}', style: const TextStyle(fontSize: 11, color: Color(0xFF84918D)))),
          ]),
        ),
      ),
    );
  }
}

class _PatientMetric extends StatelessWidget {
  const _PatientMetric({required this.label, required this.value, this.accent = false});

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF84918D))), const SizedBox(height: 3), Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: accent ? const Color(0xFF0E7C72) : const Color(0xFF17211F)))]);
}

class _PatientStats {
  const _PatientStats({required this.name, required this.initials, required this.status, required this.statusColor, required this.sessions, required this.range, required this.change, required this.lastSeen});

  final String name;
  final String initials;
  final String status;
  final Color statusColor;
  final String sessions;
  final String range;
  final String change;
  final String lastSeen;
}