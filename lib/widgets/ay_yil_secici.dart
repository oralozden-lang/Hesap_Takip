import 'package:flutter/material.dart';

// ─── Ortak Ay+Yıl Seçici Widget ──────────────────────────────────────────────
// Tüm ekranlarda aynı yapıyı sağlar: yıl chip + ay chip (şube seçimi gibi)
// Tek ay veya çoklu ardışık ay seçimi desteklenir.
// Projeksiyon gibi tek ay gereken yerlerde multiSelect: false kullanılır.

class AyYilSecici extends StatelessWidget {
  final int secilenYil;
  final Set<int> secilenAylar; // tek seçimde tek eleman olur
  final bool multiSelect; // false = tek ay seçimi (Projeksiyon/Gerçekleşen)
  final Color renk;
  final ValueChanged<int> onYilDegisti;
  final ValueChanged<Set<int>> onAylarDegisti;

  static const List<String> _aylar = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];
  static const List<String> _aylarTam = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  const AyYilSecici({
    super.key,
    required this.secilenYil,
    required this.secilenAylar,
    required this.onYilDegisti,
    required this.onAylarDegisti,
    this.multiSelect = true,
    this.renk = const Color(0xFF0288D1),
  });

  int get _ilkAy => secilenAylar.isEmpty
      ? DateTime.now().month
      : secilenAylar.reduce((a, b) => a < b ? a : b);
  int get _sonAy => secilenAylar.isEmpty
      ? DateTime.now().month
      : secilenAylar.reduce((a, b) => a > b ? a : b);

  String get donemBaslik {
    if (secilenAylar.isEmpty) return '';
    if (!multiSelect || _ilkAy == _sonAy) {
      return '${_aylarTam[_ilkAy - 1]} $secilenYil';
    }
    return '${_aylarTam[_ilkAy - 1]} – ${_aylarTam[_sonAy - 1]} $secilenYil  (${_sonAy - _ilkAy + 1} ay)';
  }

  void _aySecildi(int ay, bool v, BuildContext context) {
    if (!multiSelect) {
      // Tek seçim — sadece o ay
      onAylarDegisti({ay});
      return;
    }
    // Çoklu ardışık seçim
    final yeni = Set<int>.from(secilenAylar);
    if (v) {
      yeni.add(ay);
      if (yeni.length > 1) {
        final mn = yeni.reduce((a, b) => a < b ? a : b);
        final mx = yeni.reduce((a, b) => a > b ? a : b);
        onAylarDegisti(Set.from(List.generate(mx - mn + 1, (i) => mn + i)));
        return;
      }
    } else {
      if (yeni.length <= 1) return; // en az 1 ay seçili kalmalı
      final mn = yeni.reduce((a, b) => a < b ? a : b);
      final mx = yeni.reduce((a, b) => a > b ? a : b);
      if (ay == mn) {
        onAylarDegisti(
            Set.from(List.generate(mx - (mn + 1) + 1, (i) => mn + 1 + i)));
        return;
      } else if (ay == mx) {
        onAylarDegisti(
            Set.from(List.generate((mx - 1) - mn + 1, (i) => mn + i)));
        return;
      }
      // Ortadan çıkarma — engelle (sadece uçlardan çıkarılabilir)
      return;
    }
    onAylarDegisti(yeni);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Yıl satırı ──────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (i) => now.year - 2 + i)
                .map((y) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('$y',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: secilenYil == y
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: secilenYil == y ? renk : Colors.black87,
                            )),
                        selected: secilenYil == y,
                        onSelected: (_) => onYilDegisti(y),
                        selectedColor: renk.withOpacity(0.15),
                        checkmarkColor: renk,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // ── Ay satırı ────────────────────────────────────────────────────
        // "Tümü" chip — sadece multiSelect modunda göster
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (multiSelect)
              FilterChip(
                label: const Text('Tümü',
                    style: TextStyle(fontSize: 12)),
                selected: secilenAylar.length == 12,
                onSelected: (v) {
                  if (v) {
                    onAylarDegisti(Set.from(List.generate(12, (i) => i + 1)));
                  } else {
                    onAylarDegisti({_sonAy}); // en son seçilen ayı koru
                  }
                },
                selectedColor: renk.withOpacity(0.15),
                checkmarkColor: renk,
                labelStyle: TextStyle(
                  fontWeight: secilenAylar.length == 12
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: secilenAylar.length == 12 ? renk : Colors.black87,
                ),
              ),
            ...List.generate(12, (i) {
              final ay = i + 1;
              final secili = secilenAylar.contains(ay);
              final aralikIcinde = multiSelect &&
                  secilenAylar.isNotEmpty &&
                  ay > _ilkAy &&
                  ay < _sonAy;
              final aktif = secili || aralikIcinde;
              return FilterChip(
                label: Text(_aylar[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                      color: aktif ? renk : Colors.black87,
                    )),
                selected: aktif,
                onSelected: (v) => _aySecildi(ay, v, context),
                selectedColor: renk.withOpacity(0.15),
                checkmarkColor: renk,
                showCheckmark: !aralikIcinde,
              );
            }),
          ],
        ),
        // ── Dönem özeti ──────────────────────────────────────────────────
        if (secilenAylar.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            donemBaslik,
            style: TextStyle(
                fontSize: 12,
                color: renk,
                fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}
