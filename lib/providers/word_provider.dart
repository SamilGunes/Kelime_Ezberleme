import 'package:flutter/material.dart';
import '../database_helper.dart'; // DatabaseHelper dosyasını import et
import '../screens/quiz_screen.dart'; // QuizWord modelini kullanmak için

class WordProvider with ChangeNotifier {
  final List<QuizWord> _allWords = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<QuizWord> get allWords => _allWords;

  // Veritabanındaki kelimeleri belleğe yükleyen fonksiyon
  Future<void> loadWordsFromDatabase() async {
    final List<Map<String, dynamic>> dbWords = await _dbHelper.getAllWords();
    
    _allWords.clear();
    for (var row in dbWords) {
      _allWords.add(QuizWord(
        id: row['WordID'],
        englishWord: row['EngWordName'],
        turkishMeaning: row['TurWordName'],
        currentStage: row['Asama'] ?? 0,
        nextReviewDate: DateTime.fromMillisecondsSinceEpoch(row['SonrakiTestTarihi']),
        // 🌟 DÜZELTME: DatabaseHelper içindeki 'Picture' sütun adı ile senkronize edildi
        imagePath: row['Picture'], 
      ));
    }
    notifyListeners(); // UI'ı haberdar et
  }

  // 3. Story İsteri: Sınav ekranına sadece zamanı gelenleri filtreler
  List<QuizWord> get dailyQuizWords {
    final now = DateTime.now();
    return _allWords.where((word) {
      if (word.currentStage >= 6) return false; // 6. aşamayı tamamlayanlar elenir
      return word.nextReviewDate.isBefore(now) || word.currentStage == 0;
    }).toList();
  }

  // --- STORY-6 DİNAMİK BULMACA İÇİN EKLENEN ALAN ---
  List<String> get learnedWordsPool {
    List<String> dbWords = _allWords
        .where((w) => w.currentStage > 0)
        .map((w) => w.englishWord.toUpperCase().trim())
        .toList();

    if (dbWords.isEmpty) {
      return ['CAT', 'BOOK', 'TREE', 'NIGHT', 'WINDOW', 'SCHOOL', 'LANGUAGE', 'COMPUTER'];
    }
    return dbWords;
  }

  // --- STORY-7 AI STORY GENERATOR (LLM) İÇİN EKLENEN ALAN ---
  List<String> getRandomWordsForStory({int count = 3}) {
    List<String> pool = _allWords.map((w) => w.englishWord.toLowerCase().trim()).toList();
    
    if (pool.length < count) {
      pool.addAll(['adventure', 'mystery', 'journey', 'discovery', 'friendship', 'success']);
    }
    
    pool.shuffle();
    return pool.take(count).toList();
  }

  // Veritabanına ve Belleğe Eşzamanlı Kelime Ekleme (AI Görsel Entegrasyonlu)
  Future<void> addNewWord(String english, String turkish, String imagePath, List<String> samples) async {
    int simdikiZaman = DateTime.now().millisecondsSinceEpoch;

    // 🌟 DÜZELTME: Kelimeye özel, nokta atışı ve soyut olmayan net nesne görseli getiren Unsplash mimarisi
    String finalImagePath = imagePath;
    if (imagePath.isEmpty || imagePath == 'assets/images/placeholder.png' || !imagePath.startsWith('http')) {
      finalImagePath = "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=300&q=80&sig=${english.toLowerCase().trim().hashCode}";
    }

    // 1. SQLite Veritabanına kaydet (Ürettiğimiz görsel linkini ekliyoruz)
    int yeniId = await _dbHelper.insertWord(english, turkish, finalImagePath, simdikiZaman);

    // 2. Dinamik Örnek cümleleri veritabanına kaydet
    for (var sample in samples) {
      if (sample.isNotEmpty) {
        await _dbHelper.insertSample(yeniId, sample);
      }
    }

    // 3. Runtime Belleğe (AllWords listesine) ekle ki uygulama restart istemeden çalışsın
    _allWords.add(QuizWord(
      id: yeniId,
      englishWord: english,
      turkishMeaning: turkish,
      currentStage: 0,
      nextReviewDate: DateTime.now(),
      imagePath: finalImagePath, // Çalışma zamanı listesine de ekledik
    ));

    notifyListeners();
  }

  // Sınav ekranında doğru/yanlış yapıldığında durumu DB'de güncelleme fonksiyonu (Story 3)
  Future<void> updateWordProgressInDb(QuizWord word) async {
    await _dbHelper.updateWordStage(
      word.id, 
      word.currentStage,   
      word.nextReviewDate.millisecondsSinceEpoch,
    );
    notifyListeners();
  }

  // 🌟 YENİ EKLEME: Kelime Defterim Sayfasındaki Silme Butonunun Tam Fonksiyonel Çalışması İçin Metot
  Future<void> deleteWordFromDb(int wordId) async {
    try {
      final db = await _dbHelper.database;
      // SQLite üzerinde kelimeyi ID'sine göre uçuruyoruz
      await db.delete(
        'Words',
        where: 'WordID = ?',
        whereArgs: [wordId],
      );
      
      // Çalışma zamanı belleğinden (UI listesinden) de silip ekranı güncelliyoruz
      _allWords.removeWhere((word) => word.id == wordId);
      notifyListeners();
    } catch (e) {
      debugPrint("Kelime silinirken hata oluştu: $e");
    }
  }

  // --- 📊 LEADERBOARD İÇİN YENİ EKLENEN GÜVENLİ İSTATİSTİK FONKSİYONLARI ---
  int get totalWordsCount => _allWords.length;

  int get correctWordsCount {
    return _allWords.where((w) => w.currentStage > 0).length;
  }

  int get wrongWordsCount {
    return _allWords.where((w) => w.currentStage == 0).length;
  }

  double get successPercentage {
    if (_allWords.isEmpty) return 0.0;
    return (correctWordsCount / _allWords.length) * 100;
  }
}