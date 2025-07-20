import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tz_voucher_recharge/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Request camera permission at startup
  await Permission.camera.request();
  await Permission.phone.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TZ Voucher Recharge',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50), // Deep slate blue
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF2C3E50),
          secondary: const Color(0xFF3498DB),
          surface: Colors.grey[50],
          background: Colors.grey[50],
        ),
        
        // Modern typography
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: Color(0xFF2C3E50),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF34495E),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7F8C8D),
            height: 1.4,
          ),
        ),

        // Modern AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF2C3E50),
          ),
        ),

        // Modern elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Modern input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: const EdgeInsets.all(16),
          labelStyle: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFBDC3C7),
            fontSize: 16,
          ),
        ),

        // Modern card theme
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          color: Colors.white,
          margin: const EdgeInsets.all(8),
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: Color(0xFF7F8C8D),
          size: 24,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}