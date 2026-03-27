import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final Map<String, dynamic> currentUser; // Data dari Modul 5

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
  String _selectedCategory = 'Software';

  @override
  void initState() {
    super.initState();
    // Modul 3: Inisialisasi data lama jika sedang mode edit
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _selectedCategory = widget.log?.category ?? 'Software';

    // Modul 5: Listener untuk pratinjau Markdown real-time
    _descController.addListener(() {
      setState(() {});
    });
  }

  // --- LOGIKA WARNA ADAPTIF (UX Enhancement Modul 5) ---
  Color _getThemeColor() {
    switch (_selectedCategory) {
      case 'Electronic': return const Color.fromARGB(255, 121, 177, 222); // Soft Blue
      case 'Mechanical': return const Color.fromARGB(255, 230, 140, 170); // Soft Pink
      case 'Software': return const Color.fromARGB(255, 255, 253, 138);   // Soft Yellow
      default: return Colors.indigo;
    }
  }

  // --- LOGIKA SIMPAN (Integrasi Modul 4 & 5) ---
  void _save() {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan Deskripsi jangan kosong ya! ✨'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
      return;
    }

    if (widget.log == null) {
      // Modul 5: Tambah data dengan atribut Cloud (uid, teamId, category)
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        widget.currentUser['uid'] ?? 'unknown',
        widget.currentUser['teamId'] ?? 'no_team',
        _selectedCategory,
        isPublic: true,
      );
    } else {
      // Modul 3: Update data lokal/cloud yang sudah ada
      widget.controller.updateLog(
        widget.index!,
        _titleController.text,
        _descController.text,
        _selectedCategory,
      );
    }
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
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _getThemeColor(),
          title: Text(
            widget.log == null ? "Catatan Baru" : "Edit Catatan",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Editor", icon: Icon(Icons.edit_note, color: Colors.white)),
              Tab(text: "Pratinjau", icon: Icon(Icons.auto_awesome, color: Colors.white)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, size: 28, color: Colors.white),
              onPressed: _save,
            )
          ],
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: EDITOR ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Field Judul dengan Shadow
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Judul Catatan",
                        prefixIcon: Icon(Icons.title, color: _getThemeColor()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Kategori (Penentu Warna Kartu di LogView)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _getThemeColor().withOpacity(0.3)),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: ['Mechanical', 'Electronic', 'Software'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Editor Markdown (Modul 3)
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporanmu di sini... (Support Markdown)",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB 2: PRATINJAU (Render Markdown Modul 4) ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getThemeColor().withOpacity(0.2)),
                ),
                child: Markdown(
                  data: _descController.text.isEmpty ? "_Belum ada teks_" : _descController.text,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(color: _getThemeColor(), fontWeight: FontWeight.bold),
                    code: TextStyle(backgroundColor: Colors.grey.shade100, color: Colors.pinkAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}