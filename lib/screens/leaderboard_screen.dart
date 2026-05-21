import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // WordProvider'a bağlanıp verileri anlık çekiyoruz
    final wordProvider = Provider.of<WordProvider>(context);

    int total = wordProvider.totalWordsCount;
    int correct = wordProvider.correctWordsCount;
    int wrong = wordProvider.wrongWordsCount;
    double percentage = wordProvider.successPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarı Raporu & Sıralama', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- AKTİF İSTATİSTİK PANELİ ---
            Text(
              'Benim Performansım',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade600, Colors.indigo.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Genel Başarı Yüzdesi Dairesel İlerleme Çubuğu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Genel Başarı Oranı',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '%${percentage.toStringAsFixed(1)}',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // Sağ tarafta şık bir dairesel grafik gösterimi
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.white24,
                              color: Colors.greenAccent,
                              strokeWidth: 6,
                            ),
                          ),
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                        ],
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  // Alt Bölüm: Doğru, Yanlış ve Toplam Kartları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Toplam', total.toString(), Colors.white),
                      _buildStatItem('Doğru', correct.toString(), Colors.greenAccent),
                      _buildStatItem('Yanlış', wrong.toString(), Colors.orangeAccent),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // --- LİG / SIRALAMA SİMÜLASYONU ---
            Text(
              'Genel Sıralama (Global League)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLeaderboardRow(1, 'Ahmet Yılmaz', '%94.5', Colors.amber, false),
                  _buildLeaderboardRow(2, 'Ayşe Demir', '%88.2', Colors.grey.shade400, false),
                  _buildLeaderboardRow(3, 'Mehmet Kaya', '%81.0', Colors.orange.shade400, false),
                  // 4. Sıraya kullanıcının kendisini dinamik verileriyle yerleştiriyoruz!
                  _buildLeaderboardRow(4, 'Siz ', '%${percentage.toStringAsFixed(1)}', Colors.indigo.shade400, true),
                  _buildLeaderboardRow(5, 'Can Özkan', '%34.1', Colors.transparent, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik kutucukları oluşturucu yardımcı widget
  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Sıralama satırları oluşturucu yardımcı widget
  Widget _buildLeaderboardRow(int rank, String name, String rate, Color badgeColor, bool isMe) {
    return Container(
      color: isMe ? Colors.indigo.withOpacity(0.08) : Colors.transparent,
      // Dikey boşluğu artırarak isimlere daha ferah bir alan sağladık
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Derece Rozeti
          CircleAvatar(
            radius: 16, // Rozeti biraz büyüttük
            backgroundColor: badgeColor,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: badgeColor == Colors.transparent ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ),
          const SizedBox(width: 16),
          // İsim
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                // Kendi isminiz için ekstra kalın, diğerleri için yarı kalın
                fontWeight: isMe ? FontWeight.w900 : FontWeight.w600, 
                color: isMe ? Colors.indigo.shade700 : const Color.fromARGB(255, 189, 173, 173), // Siyah rengi güçlendirdik
                fontSize: 18, // Font boyutu artırıldı
                letterSpacing: 0.3, // Harflerin birbirine girmemesi için ufak bir boşluk
              ),
            ),
          ),
          // Skor / Oran
          Text(
            rate,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16, // Oranların boyutu da bir miktar artırıldı
              color: isMe ? Colors.indigo.shade700 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
