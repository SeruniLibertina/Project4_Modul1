import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  // === TAMBAHAN: Dialog Konfirmasi Reset ===
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
            onPressed: () {
              setState(() {
                _controller.reset();
              });

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
  // === END TAMBAHAN ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Total Hitungan:"),
              Text(
                '${_controller.value}',
                style: const TextStyle(fontSize: 40),
              ),

              const SizedBox(height: 10),
              Text("Step aktif: ${_controller.step}"),

              const SizedBox(height: 20),

              // Input Step
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

              // History Logger
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

      // Tombol + , - , dan Reset
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "plus",
            backgroundColor: Colors.green,
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "minus",
            backgroundColor: Colors.red,
            onPressed: () => setState(() => _controller.decrement()),
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
