import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  // ================= LOAD DATA SAAT MASUK =================
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadLastValue();
    setState(() {});
  }

  // ================= DIALOG RESET =================
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Reset"),
        content: const Text("Yakin ingin menghapus semua data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              _controller.reset();
              await _controller.saveLastValue();

              setState(() {});
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data berhasil di-reset"),
                ),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  // ================= DIALOG LOGOUT =================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingView(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.username} 👋"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Text(
                "Halo ${widget.username}!",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text("Total Hitungan:"),
              Text(
                '${_controller.value}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Text("Step aktif: ${_controller.step}"),

              const SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Masukkan Step",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final step = int.tryParse(value);
                  if (step != null) {
                    setState(() {
                      _controller.setStep(step);
                    });
                  }
                },
              ),

              const SizedBox(height: 20),
              const Text("Riwayat Aktivitas:"),

              Expanded(
                child: ListView(
                  children: _controller.history.map((e) {
                    Color textColor = Colors.black;

                    if (e.contains("Tambah")) {
                      textColor = Colors.green;
                    } else if (e.contains("Kurang")) {
                      textColor = Colors.red;
                    }

                    return Text(
                      e,
                      style: TextStyle(color: textColor),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "plus",
            backgroundColor: Colors.green,
            onPressed: () async {
              _controller.increment();
              await _controller.saveLastValue();
              setState(() {});
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "minus",
            backgroundColor: Colors.red,
            onPressed: () async {
              _controller.decrement();
              await _controller.saveLastValue();
              setState(() {});
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "reset",
            backgroundColor: Colors.orange,
            onPressed: _showResetDialog,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
