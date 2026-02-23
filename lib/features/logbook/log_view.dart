import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart'; // Pastikan path ini sesuai

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  // Inisialisasi controller
  final LogController _controller = LogController();
  
  // Controller untuk menangkap input teks
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Dialog Konfirmasi Logout (BARU DITAMBAHKAN)
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // Arahkan kembali ke halaman Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            // Beri warna merah agar terlihat sebagai aksi "berbahaya" (keluar)
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Dialog Tambah Data
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.addLog(
                  _titleController.text, 
                  _contentController.text
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // Dialog Edit Data
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            const SizedBox(height: 10),
            TextField(controller: _contentController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.updateLog(
                  index, 
                  _titleController.text, 
                  _contentController.text
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logbook: ${widget.username}'),
        actions: [
          // Tombol Logout di AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog, // Memanggil dialog konfirmasi
          )
        ],
      ),
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, currentLogs, child) {
          if (currentLogs.isEmpty) {
            return const Center(child: Text("Belum ada catatan logbook."));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentLogs.length,
            itemBuilder: (context, index) {
              final log = currentLogs[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.blueAccent),
                  title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(log.description),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditLogDialog(index, log),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _controller.removeLog(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}