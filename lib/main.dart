import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/login_controller.dart';
import 'features/onboarding/onboarding_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
      ],
      child: MaterialApp(
        title: 'Logbook Seruni',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF81D4FA), // Soft Blue Base
            primary: const Color(0xFF4FC3F7),   // Soft Blue Utama
            secondary: const Color(0xFFF48FB1), // Soft Pink 
            tertiary: const Color(0xFFFFF59D),  // Soft Yellow
            surface: const Color(0xFFE1F5FE),   // Background biru muda
            error: const Color(0xFFE57373),     // Merah soft
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        home: const OnboardingView(),
      ),
    );
  }
}