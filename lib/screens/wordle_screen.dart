import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  late String _targetWord; 
  late int _wordLength;    
  List<List<String>> _guesses = [];
  int _currentRow = 0;
  int _currentCol = 0;
  bool _isGameOver = false;
  String _gameMessage = 'Öğrendiğin kelimeleri tahmin et!';

  final List<String> _keyboardLetters = [
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
    'ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DELETE'
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final provider = Provider.of<WordProvider>(context, listen: false);
    List<String> wordPool = provider.learnedWordsPool;
    
    _targetWord = wordPool[Random().nextInt(wordPool.length)].toUpperCase().replaceAll(' ', '');
    _wordLength = _targetWord.length; 
    
    _guesses = List.generate(6, (_) => List.generate(_wordLength, (_) => ''));
    _currentRow = 0;
    _currentCol = 0;
    _isGameOver = false;
    _gameMessage = '$_wordLength Harfli bir kelime seçildi. Başarılar!';
  }

  // İSTER-2: Kelimeyi değiştirmek/pas geçmek için fonksiyon
  void _skipWord() {
    setState(() {
      _initGame();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kelime pas geçildi, yeni kelime yüklendi! 🔄'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  void _onKeyPress(String key) {
    if (_isGameOver) return;

    if (key == 'DELETE') {
      if (_currentCol > 0) {
        setState(() {
          _currentCol--;
          _guesses[_currentRow][_currentCol] = '';
        });
      }
    } else if (key == 'ENTER') {
      if (_currentCol == _wordLength) {
        _checkGuess();
      } else {
        setState(() {
          _gameMessage = 'Lütfen tüm kutuları doldurun ($_wordLength harf)!';
        });
      }
    } else {
      if (_currentCol < _wordLength) {
        setState(() {
          _guesses[_currentRow][_currentCol] = key;
          _currentCol++;
        });
      }
    }
  }

  void _checkGuess() {
    String currentGuess = _guesses[_currentRow].join();

    if (currentGuess == _targetWord) {
      setState(() {
        _isGameOver = true;
        _gameMessage = 'Tebrikler! Kelimeyi bildiniz: $_targetWord 🎉';
      });
      _showResultDialog(true);
    } else if (_currentRow == 5) {
      setState(() {
        _isGameOver = true;
        _gameMessage = 'Haklarınız bitti! Doğru kelime: $_targetWord 😔';
      });
      _showResultDialog(false);
    } else {
      setState(() {
        _currentRow++;
        _currentCol = 0;
        _gameMessage = 'İpuçlarını takip et ve devam et!';
      });
    }
  }

  Color _getLetterColor(int row, int col) {
    if (row >= _currentRow) return Colors.white;

    String letter = _guesses[row][col];
    
    if (_targetWord[col] == letter) {
      return Colors.green.shade600; 
    }
    if (_targetWord.contains(letter)) {
      return Colors.amber.shade700; 
    }
    return Colors.grey.shade600; 
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = _wordLength > 6 ? 38 : 46;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Bulmaca (Wordle)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Sağ üst köşeye pas geç butonu koyduk
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, size: 28),
            onPressed: _skipWord,
            tooltip: 'Kelimeyi Pas Geç',
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              _gameMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Grid Alanı
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (rowIndex) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_wordLength, (colIndex) {
                          String letter = _guesses[rowIndex][colIndex];
                          Color bgColor = _getLetterColor(rowIndex, colIndex);
                          Color textColor = bgColor == Colors.white ? Colors.black87 : Colors.white;
                          
                          return Container(
                            width: boxSize,
                            height: boxSize,
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(
                                color: rowIndex == _currentRow && colIndex == _currentCol
                                    ? Colors.indigo
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: boxSize * 0.45, 
                                fontWeight: FontWeight.bold,
                                color: textColor
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
            
            // Pas Geç Orta Buton (Ekranda kolay erişim için alternatif)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: OutlinedButton.icon(
                onPressed: _skipWord,
                icon: const Icon(Icons.autorenew),
                label: const Text('Bu Kelimeyi Pas Geç', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700),
              ),
            ),

            // Sanal Klavye
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 6,
                  children: _keyboardLetters.map((key) {
                    bool isSpecial = key == 'ENTER' || key == 'DELETE';
                    return SizedBox(
                      width: isSpecial ? 65 : 32,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSpecial ? Colors.indigo.shade400 : Colors.white,
                          foregroundColor: isSpecial ? Colors.white : Colors.black87,
                          padding: EdgeInsets.zero,
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _onKeyPress(key),
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: isSpecial ? 11 : 15, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(bool isWin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isWin ? 'Tebrikler! 🎉' : 'Oyun Bitti 😔'),
        content: Text(isWin 
            ? 'Kelimeyi başarıyla bildiniz!' 
            : 'Doğru kelime: $_targetWord\nYeniden başlamak ister misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initGame());
            },
            child: const Text('Tekrar Oyna', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}