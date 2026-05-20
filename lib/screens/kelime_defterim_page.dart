import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/word_provider.dart';
import '../screens/quiz_screen.dart'; 

class KelimeDefterimPage extends StatefulWidget {
  const KelimeDefterimPage({super.key});

  @override
  State<KelimeDefterimPage> createState() => _KelimeDefterimPageState();
}

class _KelimeDefterimPageState extends State<KelimeDefterimPage> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _ttsAyarlariniYap();
  }

  void _ttsAyarlariniYap() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _sesliOku(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // 🌟 YENİ EKLENEN KISIM: Düzenleme Penceresi (Dialog)
  void _kelimeyiDuzenleDialog(QuizWord word, int index) {
    final engController = TextEditingController(text: word.englishWord);
    final trController = TextEditingController(text: word.turkishMeaning);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Kelimeyi Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: engController,
                decoration: const InputDecoration(
                  labelText: 'İngilizce Kelime',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trController,
                decoration: const InputDecoration(
                  labelText: 'Türkçe Anlamı',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // İptal edip kapatır
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Ekranda anlık değişmesi için değerleri güncelliyoruz
                  word.englishWord = engController.text;
                  word.turkishMeaning = trController.text;
                });

                // EĞER VERİTABANI KULLANIYORSAN:
                // Provider.of<WordProvider>(context, listen: false).updateWordInDb(word);

                Navigator.pop(context); // Dialog'u kapat
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kelime başarıyla güncellendi!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = Provider.of<WordProvider>(context);
    final List<QuizWord> kelimeler = wordProvider.allWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benim Kelime Defterim', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: kelimeler.isEmpty
          ? const Center(
              child: Text(
                'Defterinizde henüz kelime bulunmuyor.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: kelimeler.length,
              itemBuilder: (context, index) {
                final currentWord = kelimeler[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // SOL TARAF: Kelimeye Özel Net Görsel Alanı
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: currentWord.imagePath != null && currentWord.imagePath!.startsWith('http')
                          ? Image.network(
                              "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=150&h=150&q=80&sig=${currentWord.englishWord.hashCode}",
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              width: 55,
                              height: 55,
                              color: Colors.teal.withOpacity(0.1),
                              child: const Icon(Icons.collections, color: Colors.teal),
                            ),
                    ),
                    title: Text(
                      currentWord.englishWord,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          currentWord.turkishMeaning,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Aşama: ${currentWord.currentStage}',
                            style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    // SAĞ TARAF: Düzenle, Dinle ve Sil Butonları
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. DÜZENLEME BUTONU (Güncellendi)
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.orangeAccent, size: 28),
                          onPressed: () {
                            // Yazdığımız açılır pencere fonksiyonunu çağırıyoruz
                            _kelimeyiDuzenleDialog(currentWord, index);
                          },
                        ),
                        // 2. SESLİ OKUMA BUTONU
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.teal),
                          onPressed: () => _sesliOku(currentWord.englishWord),
                        ),
                        // 3. AKTİF ÇALIŞAN SİLME BUTONU
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              kelimeler.removeAt(index);
                            });
                            
                            // wordProvider.deleteWordFromDb(currentWord.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Word Deleted!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}