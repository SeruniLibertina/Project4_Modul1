import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_controller.dart';
import '../logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: colors.tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 15)],
                ),
                child: Icon(Icons.lock_rounded, size: 50, color: Colors.orange.shade300),
              ),
              const SizedBox(height: 30),
              
              Card(
                elevation: 4,
                shadowColor: colors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Selamat Datang!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary)),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_rounded, color: colors.secondary)),
                          validator: (value) => (value!.isEmpty) ? 'Username wajib diisi' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.key_rounded, color: colors.secondary),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                          validator: (value) => (value!.isEmpty) ? 'Password wajib diisi' : null,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: controller.isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await controller.login(_usernameController.text, _passwordController.text);
                              if (success && mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => CounterView(username: _usernameController.text)),
                                  (route) => false,
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Login Gagal!'), backgroundColor: colors.error));
                              }
                            }
                          },
                          child: controller.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('MASUK'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}