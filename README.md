# logbook_app_001

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

PROJECT 4 : Modul 1
Proyek ini adalah hasil praktikum modul 1 yang fokus pada penerapan SRP. Di sini saya memisahkan logika aplikasi (controller) dari tampilan (vieew) agar kodenya lebih rapih dna gampang di kelola. 

Fitur yang Berhasil Dibuat :
1. Multi-step Counter : Bisa nambah atau kurangin angka sesuai nilai step yang diinput user, 
2. History Logger : ada daftar riwayat aktivitas yang muncul otomatis tiap tombol diklik. 
3. Limit History : daftar riwayat dibatas cuma muncul 5 data terbaru supaya layar nggak penuh. 
4. Warna Indikator : tulisan riwayat "tambah" berwarna hijau dan "kurang" berwarna merah biar gampang inget dan bisa ngebedainnya gak hanya dari simbolnya aja.
5. Reset Confirmation " ada dialog konfirmasi dan snackBar pas mau hapus data, jadi nggak bakal kehapus nggak sengaja. 

Refleksi SRP
Menurut saya, emnggunakan prinsip SRP ini ngebantu banget saat fitur history logger tadi, Karena logikanya dipisah ke file counter_controller.dart, saya tinggal fokus ngurusin manipulasi List di sana tanpa takut ngerusak tata letak tombol di file counter_view.dart. Jadi kodenya lebih enak dibaca apalagi pas mau debugging.