import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';

class StoryChainScreen extends StatefulWidget {
  const StoryChainScreen({super.key});

  @override
  State<StoryChainScreen> createState() => _StoryChainScreenState();
}

class _StoryChainScreenState extends State<StoryChainScreen> {
  List<String> _selectedWords = [];
  String _generatedStoryEng = '';
  String _generatedStoryTur = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickRandomWords();
  }

  void _pickRandomWords() {
    final provider = Provider.of<WordProvider>(context, listen: false);
    setState(() {
      _selectedWords = provider.getRandomWordsForStory(count: 3);
      _generatedStoryEng = '';
      _generatedStoryTur = '';
    });
  }

  void _generateAiStory() {
    if (_selectedWords.length < 3) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      String w1 = _selectedWords[0].toUpperCase();
      String w2 = _selectedWords[1].toUpperCase();
      String w3 = _selectedWords[2].toUpperCase();

      List<Map<String, String>> storyTemplates = [
        {
          'eng': 'Once upon a time, a young traveler started a journey. During this adventure, they realized that to achieve **$w1**, one must understand the hidden meaning of **$w2**. In the end, discovering the truth brought great **$w3** to the entire kingdom.',
          'tur': 'Bir zamanlar genç bir gezgin yolculuğa başladı. Bu macera sırasında, **$w1** başarısına ulaşmak için kişinin **$w2** gizli anlamını anlaması gerektiğini fark etti. Sonunda, gerçeği keşfetmek tüm krallığa büyük **$w3** getirdi.'
        },
        {
          'eng': 'In a modern city, an engineer was working on a secret project about **$w1**. Suddenly, a strange system error forced them to choose a different **$w2**. This unexpected change led to a brilliant **$w3** in technology history.',
          'tur': 'Modern bir şehirde bir mühendis, **$w1** hakkında gizli bir proje üzerinde çalışıyordu. Aniden, tuhaf bir sistem hatası onları farklı bir **$w2** seçmeye zorladı. Bu beklenmedik değişiklik, teknoloji tarihinde parlak bir **$w3** yolunu açtı.'
        },
        {
          'eng': 'The old professor opened the dusty book and pointed at **$w1**. He said that every successful **$w2** in life requires focus. His students carefully took notes, knowing this was the ultimate **$w3** for their upcoming exams.',
          'tur': 'Yaşlı profesör tozlu kitabı açtı ve **$w1** kelimesini işaret etti. Hayattaki her başarılı **$w2** sürecinin odaklanma gerektirdiğini söyledi. Öğrencileri, bunun yaklaşan sınavları için nihai **$w3** olduğunu bilerek dikkatlice not aldılar.'
        }
      ];

      final randomTemplate = storyTemplates[DateTime.now().millisecond % storyTemplates.length];

      setState(() {
        _isLoading = false;
        _generatedStoryEng = randomTemplate['eng']!;
        _generatedStoryTur = randomTemplate['tur']!;
      });
    });
  }

  // --- KRİTİK GÜNCELLEME: METİN İÇİNDEKİ ** KELİMELERİ BULUP KALIN YAPAN FONKSİYON ---
  Widget _buildFormattedText(String text, Color baseColor) {
    List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final Match match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: TextStyle(color: baseColor, fontSize: 15, height: 1.5),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: Colors.indigo.shade700, 
          fontWeight: FontWeight.bold, 
          fontSize: 16,
          backgroundColor: Colors.indigo.withOpacity(0.08)
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(color: baseColor, fontSize: 15, height: 1.5),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapay Zeka Hikaye Zinciri', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.indigo.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.indigo),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Öğrenme havuzundan rastgele seçilen 3 kelimeyle yapay zeka entegrasyonu simüle edilerek hikaye üretilir.',
                        style: TextStyle(fontSize: 13, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Zincirlenecek Kelimeler:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _selectedWords.map((word) {
                return Chip(
                  label: Text(word.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: Colors.indigo.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickRandomWords,
              icon: const Icon(Icons.refresh),
              label: const Text('Kelimeleri Değiştir'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Daha net okunması için arka planı saf beyaz yaptık
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                ),
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.indigo),
                            SizedBox(height: 16),
                            Text('Yapay Zeka Kelimeleri İşliyor...', style: TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )
                    : _generatedStoryEng.isEmpty
                        ? const Center(
                            child: Text(
                              'Hikaye üretmek için aşağıdaki butona basın.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView(
                            children: [
                              const Text('🇬🇧 English Story:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                              const SizedBox(height: 10),
                              // ARTIK ÇOK NET OKUNACAK: Colors.black87 verdik ve kalınlaştırma motorunu bağladık
                              _buildFormattedText(_generatedStoryEng, Colors.black87),
                              const Divider(height: 32, thickness: 1),
                              const Text('🇹🇷 Türkçe Çeviri:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                              const SizedBox(height: 10),
                              _buildFormattedText(_generatedStoryTur, Colors.black87),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateAiStory,
              icon: const Icon(Icons.psychology),
              label: const Text('AI Hikayesi Üret', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}