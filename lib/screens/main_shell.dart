import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'practice_screen.dart';
import 'leaderboard_screen.dart'; // Eğer dosya içindeki sınıf ismi farklıysa kontrol etmeliyiz
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // ÇÖZÜM 1: Listenin başındaki 'const' kelimesini kaldırdık!
  final List<Widget> _screens = [
    const HomeScreen(),
    const PracticeScreen(),
    const LeaderboardScreen(), // Eğer burada hâlâ hata verirse leaderboard_screen.dart dosyasındaki class ismini kontrol et
    const SettingsScreen(),
  ];

  // ÇÖZÜM 2: Buradaki 'const' kelimesini de kaldırarak dinamik elementlere izin verdik
  final List<NavigationDestination> _tabs = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined), 
      selectedIcon: Icon(Icons.home), 
      label: 'Öğren',
    ),
    const NavigationDestination(
      icon: Icon(Icons.bolt_outlined), 
      selectedIcon: Icon(Icons.bolt), 
      label: 'Pratik',
    ),
    const NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined), 
      selectedIcon: Icon(Icons.emoji_events), 
      label: 'Sıralama',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined), 
      selectedIcon: Icon(Icons.settings), 
      label: 'Ayarlar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _tabs,
      ),
    );
  }
}