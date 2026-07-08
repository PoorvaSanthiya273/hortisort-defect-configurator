import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configurator_provider.dart';

class LoginDropdown extends StatefulWidget {
  const LoginDropdown({super.key});

  @override
  State<LoginDropdown> createState() => _LoginDropdownState();
}

class _LoginDropdownState extends State<LoginDropdown> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'Operator';

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(
      builder: (context, p, _) {
        if (p.loggedIn) {
          return GestureDetector(
            onTap: () => p.logout(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFF8DAA00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFF8DAA00).withValues(alpha: 0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF8DAA00)),
                const SizedBox(width: 4),
                Text(p.role,
                    style: const TextStyle(
                        color: Color(0xFF8DAA00),
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _showLogin(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A4A4A),
                border: Border.all(
                    color: const Color(0xFF8DAA00).withValues(alpha: 0.3))),
            child: const Icon(Icons.person_outline,
                size: 16, color: Color(0xFFD8D8D8)),
          ),
        );
      },
    );
  }

  void _showLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF26384F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: SizedBox(
          width: 280,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('LOGIN',
                style: TextStyle(
                    color: Color(0xFF8DAA00),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
            TextField(
                controller: _userCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Username', Icons.person_outline)),
            const SizedBox(height: 10),
            TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Password', Icons.lock_outline)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _role,
              dropdownColor: const Color(0xFF4A4A4A),
              style: const TextStyle(color: Colors.white),
              decoration: _dec('Role', Icons.badge_outlined),
              items: ['Operator', 'Engineer', 'Admin']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => _role = v!,
            ),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DAA00),
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0),
                    onPressed: () {
                      context.read<ConfiguratorProvider>().login(
                          _userCtrl.text.trim().isEmpty
                              ? 'operator'
                              : _userCtrl.text.trim(),
                          _role);
                      Navigator.pop(ctx);
                    },
                    child: const Text('LOGIN',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2)))),
          ]),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFD8D8D8)),
        prefixIcon: Icon(icon, color: const Color(0xFFD8D8D8)),
        filled: true,
        fillColor: const Color(0xFF4A4A4A),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF8DAA00))));
  }
}
