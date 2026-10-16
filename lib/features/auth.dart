import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../core/widgets/animated_background.dart';
import 'admin.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email va parolni kiriting')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // 1. Admin tekshiruvi
      if (email == 'admin@coin.uz' && password == 'admin123') {
        ref.read(manualRoleProvider.notifier).state = 'admin';
        ref.read(loggedInUserEmailProvider.notifier).state = email;
        context.go('/admin/dashboard');
        return;
      }

      // 2. O'qituvchilar bazasidan qidirish
      final teachers = ref.read(teachersProvider);
      final teacher = teachers.firstWhere(
        (t) => t['email'] == email && t['password'] == password,
        orElse: () => <String, dynamic>{},
      );

      if (teacher.isNotEmpty) {
        ref.read(manualRoleProvider.notifier).state = 'teacher';
        ref.read(loggedInUserEmailProvider.notifier).state = email;
        context.go('/teacher/dashboard');
        return;
      }

      // 3. Talabalar bazasidan qidirish
      final students = ref.read(studentsProvider);
      final student = students.firstWhere(
        (s) => s['email'] == email && s['password'] == password,
        orElse: () => <String, dynamic>{},
      );

      if (student.isNotEmpty) {
        ref.read(manualRoleProvider.notifier).state = 'student';
        ref.read(loggedInUserEmailProvider.notifier).state = email;
        context.go('/student/dashboard');
        return;
      }

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email yoki parol noto\'g\'ri!'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 12,
                color: Colors.white.withAlpha(230),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF1E3A8A),
                        child: Icon(Icons.account_balance_wallet_rounded, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      const Text('Coin System', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: 'Parol',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('KIRISH'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
