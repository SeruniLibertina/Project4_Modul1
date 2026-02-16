import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  // Controller logic
  final LoginController _controller = LoginController();

  // Text controllers
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // UI state
  bool _obscureText = true;
  bool _isLocked = false;

  // ================= LOGIN FUNCTION =================
  void _handleLogin() async {

    if (_isLocked) return;

    String username = _userController.text.trim();
    String password = _passController.text.trim();

    // VALIDASI KOSONG
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
        ),
      );
      return;
    }

    bool success = _controller.login(username, password);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CounterView(username: username),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login Gagal! Percobaan ke-${_controller.attempt}/3",
          ),
        ),
      );

      // JIKA SALAH 3 KALI
      if (_controller.attempt >= 3) {

        setState(() {
          _isLocked = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terlalu banyak percobaan! Tunggu 10 detik."),
          ),
        );

        await Future.delayed(const Duration(seconds: 10));

        setState(() {
          _isLocked = false;
        });
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Gatekeeper"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // USERNAME
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD
            TextField(
              controller: _passController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // LOGIN BUTTON
            ElevatedButton(
              onPressed: _isLocked ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
