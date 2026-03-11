import 'package:flutter/material.dart';
import 'login_controller.dart';
import '../logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final LoginController _loginController = LoginController();

  void _doLogin() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showSnackBar("Isi dulu ya username & password-nya!", Colors.pink.shade200);
      return;
    }

    final success = await _loginController.login(_userController.text, _passController.text);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogView(currentUser: _loginController.currentUserData!)),
      );
    } else if (mounted) {
      _showSnackBar("Oops! Akunnya nggak ketemu nih", Colors.orange.shade200);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(color: Colors.black87)), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Soft Blue Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Column(
              children: [
                const Text("☁️", style: TextStyle(fontSize: 50)),
                const Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 30),
                _customField(_userController, "Username", Icons.person_outline),
                const SizedBox(height: 15),
                _customField(_passController, "Password", Icons.lock_outline, isPass: true),
                const SizedBox(height: 30),
                ListenableBuilder(
                  listenable: _loginController,
                  builder: (context, _) => ElevatedButton(
                    onPressed: _loginController.isLoading ? null : _doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCE4EC), // Soft Pink
                      foregroundColor: Colors.pink.shade700,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _loginController.isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade200),
        filled: true,
        fillColor: Colors.blue.shade50.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}