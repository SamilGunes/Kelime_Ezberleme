import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/word_provider.dart'; // Yeni eklenen WordProvider
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  // SQLite veritabanı başlatılmadan önce Flutter altyapısının hazır olmasını garantiye alıyoruz
  // Code Smells önleme: Asenkron veritabanı işlemlerinden önce mutlaka çağrılmalıdır.
  WidgetsFlutterBinding.ensureInitialized();

  // WordProvider instance'ını oluşturup veritabanından hazır kelimeleri yüklüyoruz
  final wordProvider = WordProvider();
  await wordProvider.loadWordsFromDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Veritabanı entegrasyonuna sahip WordProvider'ı buraya kaydediyoruz
        ChangeNotifierProvider.value(value: wordProvider),
      ],
      child: const MonolingoApp(),
    ),
  );
}

class MonolingoApp extends StatelessWidget {
  const MonolingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Monolingo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: authProvider.isLoggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}

class AppTheme {
  static const _green = Color(0xFF58CC02);
  static const _greenDark = Color(0xFF46A302);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          brightness: Brightness.light,
        ).copyWith(primary: _green, secondary: _greenDark),
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          brightness: Brightness.dark,
        ).copyWith(primary: _green, secondary: _greenDark),
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: const Color(0xFF131F24),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1A2E38),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}