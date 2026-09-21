import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import 'app_shell.dart';
import 'physician_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPhysician = false;
  bool _obscurePassword = true;
  bool _isSignUp = false;
  bool _checkEmail = false;
  bool _useCode = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_useCode) {
      if (_codeController.text.trim().length == 8) {
        _continueAsPhysician();
      }
      return;
    }
    if (_isSignUp) {
      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        await AuthService.signUp(_emailController.text.trim(), _passwordController.text, _isPhysician ? 'physician' : 'patient');
      }
      setState(() => _checkEmail = true);
      return;
    }
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      await AuthService.signIn(_emailController.text.trim(), _passwordController.text);
    }
    if (_isPhysician) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const PhysicianDashboard()));
      return;
    }
    _openPatientApp();
  }

  void _continueAsPhysician() {
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const PhysicianDashboard()));
  }

  void _openPatientApp() {
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => AppShell(isPhysician: _isPhysician)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: const Color(0xFF0E7C72), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 28),
            Text('Brace Yourself', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF17211F))),
            const SizedBox(height: 8),
            const Text('A clearer path through recovery.', style: TextStyle(fontSize: 16, color: Color(0xFF6D7C77))),
            const SizedBox(height: 38),
            if (_checkEmail) ...[
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFEAF5F1), borderRadius: BorderRadius.circular(18)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.mark_email_read_outlined, color: Color(0xFF0E7C72), size: 30),
                SizedBox(height: 12),
                Text('Check your email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('We sent a confirmation link. Confirm your address before signing in.', style: TextStyle(color: Color(0xFF6D7C77))),
              ])),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: const Color(0xFFE5ECE8), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: _RoleButton(label: 'Patient', icon: Icons.person_outline_rounded, selected: !_isPhysician, onPressed: () => setState(() => _isPhysician = false))),
                Expanded(child: _RoleButton(label: 'Physician', icon: Icons.medical_services_outlined, selected: _isPhysician, onPressed: () => setState(() => _isPhysician = true))),
              ]),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(child: TextButton(onPressed: () => setState(() => _isSignUp = false), child: Text('Sign in', style: TextStyle(fontWeight: !_isSignUp ? FontWeight.w800 : FontWeight.normal)))),
              Expanded(child: TextButton(onPressed: () => setState(() => _isSignUp = true), child: Text('Create account', style: TextStyle(fontWeight: _isSignUp ? FontWeight.w800 : FontWeight.normal)))),
            ]),
            TextButton.icon(onPressed: () => setState(() { _useCode = !_useCode; _isPhysician = true; }), icon: const Icon(Icons.key_rounded, size: 18), label: Text(_useCode ? 'Use email instead' : 'Use code')),
            if (_useCode) ...[
              const Text('Redeem a patient link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Enter the 8-character code or scan the patient QR.', style: TextStyle(color: Color(0xFF6D7C77))),
              const SizedBox(height: 14),
              TextField(controller: _codeController, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(labelText: 'Link code', suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner_rounded)))),
              const SizedBox(height: 12),
            ],
            Text(_isSignUp ? 'Start your recovery profile' : (_isPhysician ? 'Welcome back, doctor' : 'Welcome back'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(_isPhysician ? 'Sign in to review your patients\' progress.' : 'Sign in to continue your recovery journey.', style: const TextStyle(color: Color(0xFF6D7C77))),
            const SizedBox(height: 24),
            const Text('Email address', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.mail_outline_rounded))),
            const SizedBox(height: 16),
            const Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(hintText: 'Enter your password', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot password?'))),
            const SizedBox(height: 8),
            FilledButton(onPressed: _continue, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0E7C72), padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(_isSignUp ? 'Create account' : (_isPhysician ? 'Sign in as physician' : 'Sign in'))),
            const SizedBox(height: 18),
            OutlinedButton.icon(onPressed: _openPatientApp, icon: const Icon(Icons.g_mobiledata_rounded), label: const Text('Continue with Google'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15))),
            const SizedBox(height: 10),
            Column(children: [
              OutlinedButton.icon(onPressed: _openPatientApp, icon: const Icon(Icons.visibility_outlined), label: const Text('Preview patient app'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0E7C72), padding: const EdgeInsets.symmetric(vertical: 15))),
              const SizedBox(height: 14),
              const Text('Temporary bypass for UI preview', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF84918D))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({required this.label, required this.icon, required this.selected, required this.onPressed});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(color: selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: selected ? [const BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))] : null),
      child: TextButton.icon(onPressed: onPressed, icon: Icon(icon, size: 20), label: Text(label), style: TextButton.styleFrom(foregroundColor: selected ? const Color(0xFF0E7C72) : const Color(0xFF6D7C77), padding: const EdgeInsets.symmetric(vertical: 13))),
    );
  }
}
