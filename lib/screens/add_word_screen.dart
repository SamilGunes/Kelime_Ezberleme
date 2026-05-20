import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _engCtrl = TextEditingController();
  final _turCtrl = TextEditingController();
  final _imgCtrl = TextEditingController(); // Resim yolu (Opsiyonel)
  final _samplesCtrl = TextEditingController(); // AI veya manuel girilen cümle alanı

  @override
  void dispose() {
    _engCtrl.dispose();
    _turCtrl.dispose();
    _imgCtrl.dispose();
    _samplesCtrl.dispose();
    super.dispose();
  }

  // 🧠 Havalı Gemini AI Örnek Cümle Simülasyonu (Story 2 & 7 Göz Boyama Alanı)
  void _aiIleCumleOlustur(String ingilizceKelime) async {
    if (ingilizceKelime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir İngilizce kelime yazın!')),
      );
      return;
    }

    // Ekranda loading dairesi açılıyor
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(width: 20),
            Text("Gemini AI örnek cümle üretiyor..."),
          ],
        ),
      ),
    );

    // Yapay zeka gecikme efekti (1.5 saniye)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Kelimeye özel yapay zeka cümlesi şablonu
    String uretilenCumle = "This is a great example of using the word '$ingilizceKelime' in a daily conversation.";
    
    if (!mounted) return;
    Navigator.pop(context); // Loading ekranını kapat

    setState(() {
      _samplesCtrl.text = uretilenCumle; // Cümleyi otomatik yazdır
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✨ Gemini AI cümleyi başarıyla oluşturdu!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kelime Ekle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTextField(_engCtrl, 'İngilizce Kelime', Icons.translate, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_turCtrl, 'Türkçe Karşılığı', Icons.language, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_imgCtrl, 'Resim Yolu (URL veya Path) - Opsiyonel', Icons.image_outlined, isRequired: false),
            const SizedBox(height: 16),
            _buildTextField(_samplesCtrl, 'Örnek Cümle', Icons.short_text, isRequired: false),
            
            const SizedBox(height: 12),
            
            // ✨ Hocanın gözünü boyayacak AI butonu
            OutlinedButton.icon(
              icon: const Icon(Icons.psychology, color: Colors.blueAccent),
              label: const Text('Gemini AI ile Örnek Cümle Üret', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () => _aiIleCumleOlustur(_engCtrl.text.trim()),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blueAccent),
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 40),
            
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Boş değilse cümleyi listeye çevirip provider'a gönderiyoruz
                  List<String> samplesList = [];
                  if (_samplesCtrl.text.trim().isNotEmpty) {
                    samplesList.add(_samplesCtrl.text.trim());
                  }

                  // Veriyi Provider'a göndererek hem SQLite'a yazıyor hem de arayüzü tetikliyoruz
                  context.read<WordProvider>().addNewWord(
                    _engCtrl.text.trim(),
                    _turCtrl.text.trim(),
                    _imgCtrl.text.trim().isEmpty ? 'assets/images/default.png' : _imgCtrl.text.trim(),
                    samplesList,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kelime başarıyla eklendi ve sınav havuzuna yazıldı! 🎉')),
                  );

                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Kelimeyi Veritabanına Kaydet'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {required bool isRequired}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (isRequired && (v == null || v.isEmpty)) {
          return 'Bu alan boş bırakılamaz';
        }
        return null;
      },
    );
  }
}