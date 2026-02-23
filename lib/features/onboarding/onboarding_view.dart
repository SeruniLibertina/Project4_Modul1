import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Halo, Saya Seruni!",
      "desc": "Selamat datang di dunia LogBook yang penuh warna! Catat harimu dengan senyuman.",
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "Data Cantik",
      "desc": "Visualisasi data yang rapi dan mudah dipahami, seindah warna pelangi.",
      "image": "assets/images/onboarding2.png",
    },
    {
      "title": "Mulai Sekarang",
      "desc": "Simpan kenangan dan progresmu di sini. Aman, nyaman, dan menyenangkan!",
      "image": "assets/images/onboarding3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gambar dalam Container Putih Bulat
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          // IMPLEMENTASI CLIPRRECT DI SINI
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0), // Setengah dari lebar/tinggi gambar
                            child: Image.asset(
                              _onboardingData[index]["image"]!,
                              width: 200, // Harus sama dengan height
                              height: 200,
                              fit: BoxFit.cover, // Memastikan gambar menutupi seluruh area lingkaran
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _onboardingData[index]["title"]!,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.primary, // Soft Blue
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indikator Titik (Warna-warni)
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 12,
                        width: _currentPage == index ? 30 : 12,
                        decoration: BoxDecoration(
                          // Kalau aktif pakai Pink, kalau tidak pakai Yellow
                          color: _currentPage == index
                              ? colors.secondary 
                              : colors.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  // Tombol Lanjut
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary, // Soft Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(_currentPage == _onboardingData.length - 1 ? "Masuk" : "Lanjut"),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}