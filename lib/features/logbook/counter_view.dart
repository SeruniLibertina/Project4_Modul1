import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter_controller.dart';
import '../auth/login_controller.dart';
import '../onboarding/onboarding_view.dart';

class CounterView extends StatelessWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterController(),
      child: _CounterViewContent(username: username),
    );
  }
}

class _CounterViewContent extends StatelessWidget {
  final String username;
  const _CounterViewContent({required this.username});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CounterController>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hai, $username! ✨", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            Text("Semangat mencatat!", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            ),
            onPressed: () async {
               final auth = Provider.of<LoginController>(context, listen: false);
               await auth.logout();
               if(context.mounted) {
                 Navigator.pushAndRemoveUntil(
                   context, 
                   MaterialPageRoute(builder: (_) => const OnboardingView()), 
                   (route) => false
                 );
               }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colors.primary, const Color(0xFF81D4FA)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text("Total Hitungan", style: TextStyle(color: Colors.white)),
                  Text("${controller.count}", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Step aktif: ${controller.step}", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Masukkan Step",
                prefixIcon: Icon(Icons.tune_rounded, color: colors.secondary),
              ),
              onChanged: (value) => controller.setStep(value),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.decrement(),
                  icon: const Icon(Icons.remove),
                  label: const Text("Kurang"),
                  style: ElevatedButton.styleFrom(backgroundColor: colors.secondary),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => controller.increment(),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Align(alignment: Alignment.centerLeft, child: Text("Riwayat Aktivitas", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.history.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: colors.surface, child: Icon(Icons.history, color: colors.primary, size: 20)),
                    title: Text(controller.history[index], style: const TextStyle(fontSize: 14)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}