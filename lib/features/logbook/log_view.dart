import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../../services/access_control_service.dart';
import 'log_editor_page.dart';
import '../auth/login_view.dart';

class LogView extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    // Panggil loadLogs dengan teamId dan uid user yang sedang login
    _controller.loadLogs(widget.currentUser['teamId'], widget.currentUser['uid']);
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.currentUser['username']}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadLogs(widget.currentUser['teamId'], widget.currentUser['uid']),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
                          MaterialPageRoute(builder: (context) => const LoginView()),
                          (route) => false,
                        );
                      },
                      child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, currentLogs, child) {
          if (currentLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Belum ada catatan."),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _goToEditor(),
                    child: const Text("Buat Catatan Pertama"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: currentLogs.length,
            itemBuilder: (context, index) {
              final log = currentLogs[index];
              final bool isOwner = log.authorId == widget.currentUser['uid'];

              // --- FITUR COLOR CODING BERDASARKAN KATEGORI ---
              Color cardColor = Colors.white;
              if (log.category == 'Mechanical') {
                cardColor = Colors.green.shade100;
              } else if (log.category == 'Electronic') {
                cardColor = Colors.blue.shade100;
              } else if (log.category == 'Software') {
                cardColor = Colors.orange.shade100;
              }

              return Card(
                color: cardColor, // Menggunakan warna dari kategori
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    log.id != null ? Icons.cloud_done : Icons.cloud_upload_outlined,
                    color: log.id != null ? Colors.green : Colors.orange,
                  ),
                  title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${log.category}\n${log.description}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (AccessControlService.canPerform(
                        widget.currentUser['role'],
                        AccessControlService.actionUpdate,
                        isOwner: isOwner,
                      ))
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _goToEditor(log: log, index: index),
                        ),
                      if (AccessControlService.canPerform(
                        widget.currentUser['role'],
                        AccessControlService.actionDelete,
                        isOwner: isOwner,
                      ))
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
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}