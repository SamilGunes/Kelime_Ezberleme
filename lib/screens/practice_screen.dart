import 'package:flutter/material.dart';
import 'wordle_screen.dart';
import 'story_chain_screen.dart'; // Yapay Zeka ekranını import ettik

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratik ve Oyunlar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. OYUN: WORDLE KELİME BULMACASI KARTI
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Tıklanınca Wordle ekranını yeni sayfada açıyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordleScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.grid_on_rounded, size: 36, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelime Bulmaca (Wordle)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Öğrendiğin kelimeleri harf ipuçlarıyla tahmin et!',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. OYUN: YAPAY ZEKA HİKAYE ZİNCİRİ KARTI (AKTİF EDİLDİ 🚀)
          Card(
            elevation: 3, // Görünürlüğü artırmak için gölge eklendi
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Tıklanınca Yapay Zeka Hikaye Zinciri ekranını açıyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StoryChainScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, size: 36, color: Colors.indigo),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yapay Zeka Hikaye Zinciri',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Soluk renk kaldırıldı
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelimelerini kullanarak akıllı hikayeler ve çeviriler üret!',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}