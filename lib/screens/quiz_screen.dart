import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';

// 3. Story için Kelime İlerleme ve Veri Yapısı (KISS Prensibi)
class QuizWord {
  final int id;
  String englishWord;
  String turkishMeaning;
  int currentStage;
  DateTime nextReviewDate;
  final String? imagePath; // 🌟 AI Görsel Adresi için alan eklendi

  QuizWord({
    required this.id,
    required this.englishWord,
    required this.turkishMeaning,
    this.currentStage = 0,
    required this.nextReviewDate,
    this.imagePath, // 🌟 Constructor'a dahil edildi
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // 6 Sefer Tekrar Prensibi Zaman Aralıkları
  final List<Duration> _reviewIntervals = const [
    Duration(days: 1),    // 1. Doğru sonrası
    Duration(days: 7),    // 2. Doğru sonrası (1 hafta)
    Duration(days: 30),   // 3. Doğru sonrası (1 ay)
    Duration(days: 90),   // 4. Doğru sonrası (3 ay)
    Duration(days: 180),  // 5. Doğru sonrası (6 ay)
    Duration(days: 365),  // 6. Doğru sonrası (1 yıl)
  ];

  // Çeldirici kelimeler havuzu
  final List<String> _distractors = ['Araba', 'Kitap', 'Masa', 'Kedi', 'Kalem', 'Su', 'Ev', 'Ağaç'];

  List<QuizWord> _quizPool = []; 
  int _currentIndex = 0;
  bool _isAnswered = false;
  String _selectedAnswer = '';
  List<String> _shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WordProvider>(context, listen: false);
    _quizPool = provider.dailyQuizWords;
    
    if (_quizPool.isNotEmpty) {
      _generateOptions();
    }
  }

  QuizWord get _currentQuestion => _quizPool[_currentIndex];

  void _generateOptions() {
    _shuffledOptions = [_currentQuestion.turkishMeaning];
    
    List<String> tempDistractors = List.from(_distractors)..shuffle();
    for (var dist in tempDistractors) {
      if (dist != _currentQuestion.turkishMeaning && _shuffledOptions.length < 4) {
        _shuffledOptions.add(dist);
      }
    }
    
    _shuffledOptions.shuffle();
  }

  void _checkAnswer(String selectedOption) {
    final provider = Provider.of<WordProvider>(context, listen: false);

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selectedOption;
    });

    bool isCorrect = (selectedOption == _currentQuestion.turkishMeaning);

    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }

    provider.updateWordProgressInDb(_currentQuestion);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentIndex < _quizPool.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswer = '';
          _generateOptions(); 
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _handleCorrectAnswer() {
    if (_currentQuestion.currentStage < 6) {
      Duration nextInterval = _reviewIntervals[_currentQuestion.currentStage];
      _currentQuestion.currentStage++;
      _currentQuestion.nextReviewDate = DateTime.now().add(nextInterval);
    }
  }

  void _handleWrongAnswer() {
    _currentQuestion.currentStage = 0; 
    _currentQuestion.nextReviewDate = DateTime.now(); 
  }

  @override
  Widget build(BuildContext context) {
    if (_quizPool.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('6 Aşamalı Quiz')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Bugün için sınav zamanı gelmiş bir kelime bulunmuyor.\nYeni kelimeler ekleyerek havuzu besleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('6 Aşamalı Quiz', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _quizPool.length,
                backgroundColor: Colors.grey.shade200,
                color: Colors.indigo,
                minHeight: 8,
              ),
              const SizedBox(height: 24),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Mevcut Aşama: ${_currentQuestion.currentStage} / 6',
                          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🌟 AI GÖRSEL ALANI: Soru kartının içine kelimenin yapay zeka resmini basıyoruz
                      if (_currentQuestion.imagePath != null && _currentQuestion.imagePath!.startsWith('http'))
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: double.infinity,
                          height: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _currentQuestion.imagePath!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),

                      Text(
                        _currentQuestion.englishWord,
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              ..._shuffledOptions.map((option) => _buildOptionButton(option)),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String optionText) {
    Color buttonColor = Colors.white;
    Color textColor = Colors.black87;

    if (_isAnswered) {
      if (optionText == _currentQuestion.turkishMeaning) {
        buttonColor = Colors.green.shade600;
        textColor = Colors.white;
      } else if (optionText == _selectedAnswer) {
        buttonColor = Colors.red.shade600;
        textColor = Colors.white;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(18),
          side: BorderSide(
            color: _isAnswered && (optionText == _currentQuestion.turkishMeaning || optionText == _selectedAnswer)
                ? Colors.transparent
                : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _isAnswered ? null : () => _checkAnswer(optionText),
        child: Text(
          optionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Harika! Test Tamamlandı 🎉'),
        content: const Text('Kelimelerin durumları algoritma doğrultusunda güncellendi.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}