import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/UserProvider.dart';
import 'homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color black = Color(0xFF1C1C1E);
  static const Color gold = Color(0xFFC9A24D);
  static const Color background = Color(0xFFF5F5F7);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isRegister = false;
  bool hidePassword = true;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      showMessage('Please enter username and password');
      return;
    }

    if (isRegister && (name.isEmpty || email.isEmpty)) {
      showMessage('Please enter your name and email');
      return;
    }

    final provider = context.read<UserProvider>();

    final success = isRegister
        ? await provider.register(name, email, username, password)
        : await provider.login(username, password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const homeScreen()),
      );
    } else {
      showMessage(
        provider.error ?? (isRegister ? 'Registration failed' : 'Login failed'),
      );
    }
  }

  void toggleMode() {
    setState(() {
      isRegister = !isRegister;
    });
  }

  InputDecoration fieldDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: black),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hotel, size: 52, color: gold),
                ),
                const SizedBox(height: 24),
                Text(
                  isRegister ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                if (isRegister) ...[
                  TextField(
                    controller: nameController,
                    decoration: fieldDecoration('Full Name', Icons.badge),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration('Email', Icons.email),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: usernameController,
                  decoration: fieldDecoration('Username', Icons.person),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: fieldDecoration(
                    'Password',
                    Icons.lock,
                    suffix: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<UserProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: black,
                          foregroundColor: gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: provider.isLoading ? null : submit,
                        child: provider.isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: gold,
                          ),
                        )
                            : Text(
                          isRegister ? 'Register' : 'Login',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: toggleMode,
                  child: Text(
                    isRegister
                        ? 'Already have an account? Login'
                        : "Don't have an account? Register",
                    style: const TextStyle(color: black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}