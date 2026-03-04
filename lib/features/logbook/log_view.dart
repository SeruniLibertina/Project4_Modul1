import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:intl/intl.dart'; // Package tambahan untuk format tanggal

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  // Inisialisasi controller
  late LogController _controller;
  
  // Controller untuk menangkap input teks
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Variabel untuk menyimpan kategori yang dipilih saat input
  String _selectedCategory = 'Pribadi';
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent', 'Umum'];

  // Variabel Cloud & Search
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    // Memulai koneksi ke MongoDB saat layar dibuka
    Future.microtask(() => _initDatabase());
  }

  // FUNGSI KONEKSI CLOUD MONGODB
  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog("UI: Menghubungi MongoService.connect()...", source: "log_view.dart");
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi Cloud Timeout. Periksa IP Whitelist (0.0.0.0/0)."),
      );
      await _controller.loadFromDisk();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah Koneksi: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi pewarnaan Card dengan tema Pastel Aesthetic
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return const Color(0xFFE0F2FE); // Soft Blue
      case 'Pribadi':
        return const Color(0xFFFFE4E1); // Soft Pink
      case 'Urgent':
        return const Color(0xFFFEF9C3); // Soft Yellow
      default:
        return Colors.white; // Umum tetap putih
    }
  }

  // Dialog Konfirmasi Logout
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal", style: TextStyle(color: Colors.black87)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
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
    _selectedCategory = 'Pribadi'; 
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Tambah Catatan Baru"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Column(
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
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setStateDialog(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2FE),
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                // Panggil AddLog dari Controller (Akan otomatis masuk ke Cloud)
                _controller.addLog(
                  _titleController.text, 
                  _contentController.text,
                  _selectedCategory,
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
    _selectedCategory = log.category; 
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Catatan"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController),
                const SizedBox(height: 10),
                TextField(controller: _contentController),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _categories.contains(_selectedCategory) ? _selectedCategory : 'Umum',
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setStateDialog(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2FE),
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.updateLog(
                  index, 
                  _titleController.text, 
                  _contentController.text,
                  _selectedCategory,
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
      backgroundColor: const Color(0xFFFAFAFA), 
      appBar: AppBar(
        title: Text(
          'Logbook: ${widget.username}', 
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _showLogoutConfirmationDialog, 
          )
        ],
      ),
      body: Column(
        children: [
          // Fitur Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                labelText: "Cari Catatan...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.black45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier, 
              builder: (context, currentLogs, child) {
                
                // 1. Indikator Loading Cloud
                if (_isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Membuka Koneksi Atlas...", style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  );
                }

                // Melakukan filter pencarian (Mencegah salah hapus index)
                final displayLogs = currentLogs.where((log) => 
                  log.title.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                // 2. Jika Data Kosong
                if (displayLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.speaker_notes_off, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          currentLogs.isEmpty ? "Belum ada catatan di Cloud." : "Pencarian tidak ditemukan.",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }
                
                // 3. Menampilkan List Data dengan RefreshIndicator (PULL-TO-REFRESH)
                return RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadFromDisk();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Data berhasil diperbarui!", style: TextStyle(color: Colors.black87)),
                          backgroundColor: Color(0xFFE0F2FE),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayLogs.length,
                    itemBuilder: (context, index) {
                      final log = displayLogs[index];
                      
                      // Mendapatkan index asli dari data utama
                      final realIndex = currentLogs.indexOf(log); 

                      // PROSES FORMAT TANGGAL MENGGUNAKAN PACKAGE INTL
                      String formattedDate = "";
                      try {
                        DateTime parsedDate = DateTime.parse(log.date);
                        formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
                      } catch (e) {
                        formattedDate = "Tanggal tidak valid";
                      }

                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCDD2), 
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                        ),
                        onDismissed: (direction) {
                          _controller.removeLog(realIndex);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Catatan dihapus dari Cloud", style: TextStyle(color: Colors.black87)),
                              backgroundColor: Color(0xFFFEF9C3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Card(
                          color: _getCategoryColor(log.category),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.black.withOpacity(0.05)),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.cloud_done_outlined, color: Colors.black87),
                              ),
                              title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(log.description, style: const TextStyle(color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  
                                  // MENAMPILKAN KATEGORI DAN TANGGAL BERDAMPINGAN
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          log.category, 
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w500)
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: -8, 
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                                    onPressed: () => _showEditLogDialog(realIndex, log),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      _controller.removeLog(realIndex);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Catatan dihapus dari Cloud", style: TextStyle(color: Colors.black87)),
                                          backgroundColor: Color(0xFFFEF9C3), 
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: const Color(0xFFE0F2FE), 
        foregroundColor: Colors.black87,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}