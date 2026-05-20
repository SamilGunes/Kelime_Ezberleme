import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kelime_ezber.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Story 1: Kullanıcı Tablosu
    await db.execute('''
      CREATE TABLE Users (
        UserID INTEGER PRIMARY KEY AUTOINCREMENT,
        Username TEXT,
        Password TEXT
      )
    ''');

    // Story 2 & 3: Kelime Tablosu
    await db.execute('''
      CREATE TABLE Words (
        WordID INTEGER PRIMARY KEY AUTOINCREMENT,
        EngWordName TEXT,
        TurWordName TEXT,
        Picture TEXT, -- 🌟 AI Görsel URL'sini tutan sütunumuz
        Asama INTEGER DEFAULT 0,
        SonrakiTestTarihi INTEGER
      )
    ''');

    // Story 2: Örnek Cümleler Tablosu
    await db.execute('''
      CREATE TABLE WordSamples (
        SampleID INTEGER PRIMARY KEY AUTOINCREMENT,
        WordID INTEGER,
        Samples TEXT,
        FOREIGN KEY (WordID) REFERENCES Words (WordID) ON DELETE CASCADE
      )
    ''');

    // Başlangıç Kelimeleri (Seed Data)
    List<Map<String, dynamic>> oxfordKelimeleri = [
      {'ingilizce': 'persistent', 'turkce': 'inatçı, ısrarcı', 'cumle': 'He is persistent in his academic goals.'},
      {'ingilizce': 'achieve', 'turkce': 'başarmak', 'cumle': 'You can achieve anything if you work hard.'},
      {'ingilizce': 'opportunity', 'turkce': 'fırsat', 'cumle': 'Studying abroad is a great opportunity.'},
      {'ingilizce': 'essential', 'turkce': 'gerekli, temel', 'cumle': 'Water is essential for living things.'},
      {'ingilizce': 'improve', 'turkce': 'geliştirmek', 'cumle': 'I practice daily to improve my English.'},
    ];

    int simdikiZaman = DateTime.now().millisecondsSinceEpoch;
    
    for (var kelime in oxfordKelimeleri) {
      // 🌟 BAŞLANGIÇ KELİMELERİNE DE YAPAY ZEKA GÖRSELİ TANIMLIYORUZ
      String engWord = kelime['ingilizce']!;
      String aiImageUrl = "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format&fit=crop&w=300&q=80&sig=${engWord.hashCode}";

      int yeniWordID = await db.insert('Words', {
        'EngWordName': engWord,
        'TurWordName': kelime['turkce'],
        'Picture': aiImageUrl, // 🌟 Boş bırakmak yerine AI Linkini ekledik
        'Asama': 0,
        'SonrakiTestTarihi': simdikiZaman 
      });

      await db.insert('WordSamples', {
        'WordID': yeniWordID,
        'Samples': kelime['cumle']
      });
    }
  }

  // --- ENTEGRASYON İÇİN EKLENEN YENİ FONKSİYONLAR ---

  // Tüm kelimeleri veritabanından çekme
  Future<List<Map<String, dynamic>>> getAllWords() async {
    final db = await database;
    return await db.query('Words');
  }

  // Veritabanına yeni kelime ekleme
  Future<int> insertWord(String eng, String tur, String pic, int sonrakiTest) async {
    final db = await database;
    return await db.insert('Words', {
      'EngWordName': eng,
      'TurWordName': tur,
      'Picture': pic, // 🌟 Provider'dan gelen AI linki buraya yazılıyor
      'Asama': 0,
      'SonrakiTestTarihi': sonrakiTest,
    });
  }

  // Kelimenin aşamasını ve sonraki test tarihini veritabanında güncelleme (Story 3 için)
  Future<void> updateWordStage(int wordId, int yeniAsama, int sonrakiTestTarihi) async {
    final db = await database;
    await db.update(
      'Words',
      {
        'Asama': yeniAsama,
        'SonrakiTestTarihi': sonrakiTestTarihi,
      },
      where: 'WordID = ?',
      whereArgs: [wordId],
    );
  }

  // Kelimeye ait dinamik cümleleri ekleme (Story 2 için)
  Future<void> insertSample(int wordId, String sampleText) async {
    final db = await database;
    await db.insert('WordSamples', {
      'WordID': wordId,
      'Samples': sampleText,
    });
  }
}