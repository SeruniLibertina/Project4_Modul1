import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  
  // Menerima data user yang sedang login (isinya uid, role, teamId, dll)
  final Map<String, dynamic> currentUser; 

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');

    // Listener agar Tab Pratinjau (Markdown) ter-update otomatis saat kita mengetik
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Deskripsi tidak boleh kosong!')),
      );
      return;
    }

    if (widget.log == null) {
      // Tambah Data Baru
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        widget.currentUser['uid'] ?? 'unknown_uid',
        widget.currentUser['teamId'] ?? 'no_team',
      );
    } else {
      // Update Data Lama
      widget.controller.updateLog(
        widget.index!,
        _titleController.text,
        _descController.text,
      );
    }
    
    // Tutup halaman setelah simpan
    Navigator.pop(context); 
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor", icon: Icon(Icons.edit_note)),
              Tab(text: "Pratinjau", icon: Icon(Icons.preview)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Simpan',
              onPressed: _save,
            )
          ],
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: AREA KETIK (EDITOR) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Judul Catatan",
                      hintText: "Contoh: Logika Sensor Jarak",
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null, // Agar textfield bisa memanjang ke bawah
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporan Anda dengan format Markdown di sini...\n\nGunakan # untuk Judul\nGunakan **teks** untuk tebal\nGunakan ``` untuk kode",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB 2: PRATINJAU MARKDOWN ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _descController.text.isEmpty
                  ? const Center(child: Text("Belum ada teks untuk dipratinjau."))
                  : MarkdownBody(
                      data: _descController.text,
                      selectable: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}