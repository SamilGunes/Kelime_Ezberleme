import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart'; 
import '../providers/word_provider.dart';
import 'add_word_screen.dart';
import 'quiz_screen.dart';
import 'kelime_defterim_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _sesMotorunuAyarla();
  }

  void _sesMotorunuAyarla() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _sesliOku(String text) async {
    if (text.isNotEmpty) await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = Provider.of<WordProvider>(context);
    final bool hasWords = wordProvider.totalWordsCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LingoLingo', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: hasWords ? _buildDashboard(context, wordProvider) : _buildEmptyState(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddWordScreen()));
        },
        label: const Text('Kelime Ekle'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📚', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('Kelime Havuzun Boş', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text('Öğrenmeye başlamak için sağ alttaki butondan kelime ekle.', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WordProvider provider) {
    int dailyCount = provider.dailyQuizWords.length;
    String dailyWordEng = provider.allWords.isNotEmpty ? provider.allWords.first.englishWord.toUpperCase() : 'LEARN';
    String dailyWordTur = provider.allWords.isNotEmpty ? provider.allWords.first.turkishMeaning : 'Öğrenmek';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Günlük Durum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: Colors.amber.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dailyCount > 0 
                        ? 'Bugün tekrarlaman gereken $dailyCount kelime var! Hafızanı tazelemeye ne dersin?' 
                        : 'Harika! Bugün tekrarlanacak tüm kelimelerini tamamladın.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Text('Öğrenme Modülleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          ActionCard(
            title: '6 Aşamalı Sınav',
            subtitle: 'Kelimeleri Leitner sistemiyle kalıcı hafızaya aktar',
            icon: Icons.school_rounded,
            color: Colors.blueAccent,
            badgeText: dailyCount > 0 ? '$dailyCount' : null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
          ),
          
          const SizedBox(height: 12),

          ActionCard(
            title: '📚 Benim Kelime Defterim',
            subtitle: 'Tüm kelimelerini gör, dinle, düzenle veya sil',
            icon: Icons.menu_book_rounded,
            color: Colors.teal,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KelimeDefterimPage()));
            },
          ),
          
          const SizedBox(height: 20),
          const Text('Günün Kelimesi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dailyWordEng, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.indigo.shade700)),
                      const SizedBox(height: 4),
                      Text(dailyWordTur, style: TextStyle(fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.indigo, size: 28),
                    onPressed: () => _sesliOku(dailyWordEng),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// SINIFIN DIŞINDA TANIMLANMIŞ ACTIONCARD WIDGET'I
class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badgeText;
  final VoidCallback onTap;

  const ActionCard({
    super.key, required this.title, required this.subtitle,
    required this.icon, required this.color, this.badgeText, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text(badgeText!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}