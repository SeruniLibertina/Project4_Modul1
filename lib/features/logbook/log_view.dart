import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'log_controller.dart';
import 'models/log_model.dart';
import '../../services/access_control_service.dart';
import 'log_editor_page.dart';
import '../auth/login_view.dart';
import '../auth/login_controller.dart'; 

class LogView extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  String _searchQuery = ''; 
  bool _isOnline = true; 

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    _checkConnectivity(); 
    _controller.loadLogs(widget.currentUser['teamId'], widget.currentUser['uid']);
    
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    var results = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;
      });
    }
  }

  String _getRelativeTime(String dateStr) {
    try {
      DateTime logDate = DateTime.parse(dateStr);
      Duration diff = DateTime.now().difference(logDate);

      if (diff.inMinutes < 1) return "Baru saja";
      if (diff.inMinutes < 60) return "${diff.inMinutes} menit lalu 🎀";
      if (diff.inHours < 24) return "${diff.inHours} jam lalu 🎀";
      if (diff.inDays < 7) return "${diff.inDays} hari lalu 🎀";
      return dateStr.split(' ')[0]; 
    } catch (e) {
      return "Waktu rahasia";
    }
  }

  // --- PALETTE WARNA PASTEL AESTHETIC ---
  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Electronic': return const Color(0xFFE3F2FD); // Soft Blue
      case 'Mechanical': return const Color(0xFFFCE4EC); // Soft Pink
      case 'Software': return const Color(0xFFFFF9C4);   // Soft Yellow
      default: return const Color(0xFFFFF0F5); // Lavender Blush
    }
  }
  
  Color _getTextColor(String? category) {
    switch (category) {
      case 'Electronic': return Colors.blue.shade800;
      case 'Mechanical': return Colors.pink.shade800;
      case 'Software': return Colors.orange.shade900;
      default: return Colors.brown.shade600;
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F8), // Soft pink background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Pamit dulu?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        content: const Text("Yakin mau keluar? Tenang aja, semua rahasia catatanmu aman tersimpan kok! 🎀"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Nggak jadi", style: TextStyle(color: Colors.pink.shade300))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade200, 
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            onPressed: () async {
              await LoginController().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (r) => false);
              }
            },
            child: const Text("Iya, Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Hapus Catatan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Kalau dihapus, kenangannya bakal hilang selamanya lho... Yakin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900, elevation: 0),
            onPressed: () {
              _controller.removeLog(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Catatan sudah dibuang"),
                backgroundColor: Colors.pink.shade200,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ));
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogEditorPage(log: log, index: index, controller: _controller, currentUser: widget.currentUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8), // Background Lavender Blush super manis
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 90,
        backgroundColor: Colors.transparent, // Transparan agar menyatu dengan background
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Diary, ${widget.currentUser['username']} 🌸", 
              style: TextStyle(color: Colors.pink.shade400, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Comic Sans MS')), // Jika punya font custom, lebih bagus!
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pink.shade100)),
              child: Text("${widget.currentUser['teamId']} 🎀 ${widget.currentUser['role']}", 
                style: TextStyle(color: Colors.pink.shade300, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10)]),
              child: IconButton(icon: Icon(Icons.logout_rounded, color: Colors.pink.shade300), onPressed: _confirmLogout),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH BAR GIRLY ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.pink.shade50, width: 2),
                boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Cari kenangan hari ini...",
                  hintStyle: TextStyle(color: Colors.pink.shade200),
                  prefixIcon: Icon(Icons.favorite_rounded, color: Colors.pink.shade100),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {
                final filtered = currentLogs.where((l) => 
                  l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (l.category ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🧸", style: TextStyle(fontSize: 70)),
                        const SizedBox(height: 16),
                        Text(currentLogs.isEmpty ? "Buku harianmu masih kosong nih~" : "Ups, catatan tidak ketemu 🎀", 
                          style: TextStyle(color: Colors.pink.shade200, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    final realIndex = currentLogs.indexOf(log); 
                    final bool isOwner = log.authorId == widget.currentUser['uid'];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(log.category),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 3), // Efek stiker putih di pinggiran
                        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Badge Kategori
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                                  child: Text(log.category?.toUpperCase() ?? "UMUM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _getTextColor(log.category), letterSpacing: 1)),
                                ),
                                if (isOwner) 
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20), // Tanda "Milik Anda" yang lebih imut
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            Text(log.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _getTextColor(log.category))),
                            const SizedBox(height: 4),
                            Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: _getTextColor(log.category).withOpacity(0.7))),
                            
                            const SizedBox(height: 16),
                            
                            // --- BOTTOM ROW: STATUS & ACTIONS ---
                            Row(
                              children: [
                                // Waktu dibuat
                                Icon(Icons.access_time_rounded, size: 14, color: _getTextColor(log.category).withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text(_getRelativeTime(log.date), style: TextStyle(fontSize: 11, color: _getTextColor(log.category).withOpacity(0.6), fontWeight: FontWeight.w600)),
                                
                                const Spacer(),
                                
                                if (AccessControlService.canPerform(widget.currentUser['role'], 'update', isOwner: isOwner))
                                  _cuteButton(Icons.edit_rounded, Colors.white, _getTextColor(log.category), () => _goToEditor(log: log, index: realIndex)),
                                const SizedBox(width: 10),
                                if (AccessControlService.canPerform(widget.currentUser['role'], 'delete', isOwner: isOwner))
                                  _cuteButton(Icons.delete_rounded, Colors.white, Colors.red.shade300, () => _confirmDelete(realIndex)),
                              ],
                            ),

                            const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(height: 1, color: Colors.white60, thickness: 1.5)),

                            // --- INDIKATOR STATUS CLOUD DI DALAM KARTU ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Sinkronisasi Hive ke MongoDB
                                Row(
                                  children: [
                                    Icon(log.id != null ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded, size: 14, color: log.id != null ? Colors.green.shade400 : Colors.orange.shade400),
                                    const SizedBox(width: 4),
                                    Text(log.id != null ? "Tersimpan ☁️" : "Pending 🌧️", style: TextStyle(fontSize: 11, color: log.id != null ? Colors.green.shade600 : Colors.orange.shade600, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                // Koneksi Global ke MongoDB
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Icon(_isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded, size: 12, color: _isOnline ? Colors.pink.shade300 : Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(_isOnline ? "Online 🎀" : "Offline 🥀", style: TextStyle(fontSize: 10, color: _isOnline ? Colors.pink.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // --- PERBAIKAN FAB (Menghapus property shadowColor yang bikin error) ---
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade200.withOpacity(0.6), 
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.pink.shade300,
          elevation: 0, // Matikan elevasi bawaan karena sudah diganti Container shadow
          onPressed: () => _goToEditor(),
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          label: const Text("Catat! ✨", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _cuteButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: iconColor.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2))]),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}