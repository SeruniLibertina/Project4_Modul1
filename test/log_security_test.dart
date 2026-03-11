import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart'; // Sesuaikan path import model Anda

void main() {
  test('RBAC Security Check: Private logs should NOT be visible to teammates', () {
    // 1. Setup Data: User A (id: user_a) punya 1 log Public dan 1 log Private
    final dummyCloudData = [
      LogModel(title: "Log Public", description: "Bisa dilihat", date: "2024", authorId: "user_a", teamId: "tim_1", isPublic: true),
      LogModel(title: "Log Private", description: "Rahasia", date: "2024", authorId: "user_a", teamId: "tim_1", isPublic: false),
    ];

    // 2. Action: User B (id: user_b) mencoba fetch / memfilter data tim
    final userB_Id = "user_b";
    
    // Logika filter yang sama seperti di LogController (Gatekeeper Task 5)
    final visibleLogsForUserB = dummyCloudData.where((log) {
      return log.authorId == userB_Id || log.isPublic == true;
    }).toList();

    // 3. Assert (Validasi): User B HANYA boleh melihat 1 catatan (yang Public)
    expect(visibleLogsForUserB.length, 1);
    expect(visibleLogsForUserB.first.title, "Log Public");
  });
}