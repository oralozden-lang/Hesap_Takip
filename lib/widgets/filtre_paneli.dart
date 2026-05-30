import 'package:flutter/material.dart';

const Color _anaRenk = Color(0xFF0288D1);
const Color _karsRenk = Color(0xFF546E7A);

const List<String> _aylarKisa = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];
const List<String> _aylarTam = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

class FiltrePaneli extends StatefulWidget {
  // ── Dönem ──────────────────────────────────────────────────────────────────
  final int secilenYil;
  final Set<int> secilenAylar;       // boş = tümü
  final String filtreModu;           // 'ay' | 'aralik'
  final DateTime baslangic;
  final DateTime bitis;
  final bool tarihAralikGoster;
  final ValueChanged<int> onYilDegisti;
  final ValueChanged<Set<int>> onAylarDegisti;
  final ValueChanged<String> onFiltreModu;
  final ValueChanged<DateTime> onBaslangicDegisti;
  final ValueChanged<DateTime> onBitisDegisti;

  // ── Şube ───────────────────────────────────────────────────────────────────
  final Map<String, String> subeler;  // id → ad
  final Set<String> secilenSubeler;   // boş = tümü
  final bool subeGoster;
  final ValueChanged<Set<String>> onSubelerDegisti;

  // ── Karşılaştırma ──────────────────────────────────────────────────────────
  final bool karsilastirmaGoster;
  final bool karsilastirmaAcik;
  final int karsilastirmaYil;
  final int karsilastirmaAy;
  final DateTime? karsilastirmaBaslangic;
  final DateTime? karsilastirmaBitis;
  final ValueChanged<bool> onKarsilastirmaToggle;
  final ValueChanged<int> onKarsilastirmaYilDegisti;
  final ValueChanged<int> onKarsilastirmaAyDegisti;
  final ValueChanged<DateTime> onKarsilastirmaBaslangicDegisti;
  final ValueChanged<DateTime> onKarsilastirmaBitisDegisti;

  // ── Ekstra slot (Ödeme Kanalları için kanal seçimi gibi) ──────────────────
  final Widget? ekstraFiltre;

  // ── Buton ──────────────────────────────────────────────────────────────────
  final String butonMetni;
  final VoidCallback onGoster;

  const FiltrePaneli({
    super.key,
    required this.secilenYil,
    required this.secilenAylar,
    required this.filtreModu,
    required this.baslangic,
    required this.bitis,
    required this.onYilDegisti,
    required this.onAylarDegisti,
    required this.onFiltreModu,
    required this.onBaslangicDegisti,
    required this.onBitisDegisti,
    this.tarihAralikGoster = true,
    this.subeler = const {},
    this.secilenSubeler = const {},
    this.subeGoster = true,
    required this.onSubelerDegisti,
    this.karsilastirmaGoster = true,
    this.karsilastirmaAcik = false,
    this.karsilastirmaYil = 0,
    this.karsilastirmaAy = 1,
    this.karsilastirmaBaslangic,
    this.karsilastirmaBitis,
    required this.onKarsilastirmaToggle,
    required this.onKarsilastirmaYilDegisti,
    required this.onKarsilastirmaAyDegisti,
    required this.onKarsilastirmaBaslangicDegisti,
    required this.onKarsilastirmaBitisDegisti,
    this.ekstraFiltre,
    this.butonMetni = 'Raporu Getir',
    required this.onGoster,
  });

  @override
  State<FiltrePaneli> createState() => _FiltrePaneliState();
}

class _FiltrePaneliState extends State<FiltrePaneli> {
  bool _donemAcik = false;
  bool _subeAcik = false;
  bool _karsDonemAcik = false;

  int get _ilkAy => widget.secilenAylar.isEmpty
      ? 1
      : widget.secilenAylar.reduce((a, b) => a < b ? a : b);
  int get _sonAy => widget.secilenAylar.isEmpty
      ? 12
      : widget.secilenAylar.reduce((a, b) => a > b ? a : b);

  String get _donemBaslik {
    if (widget.filtreModu == 'aralik') {
      final b = widget.baslangic;
      final e = widget.bitis;
      return '${_pad(b.day)}.${_pad(b.month)}.${b.year} – ${_pad(e.day)}.${_pad(e.month)}.${e.year}';
    }
    if (widget.secilenAylar.isEmpty || widget.secilenAylar.length == 12) {
      return 'Tüm Aylar ${widget.secilenYil}';
    }
    if (widget.secilenAylar.length == 1) {
      return '${_aylarTam[_ilkAy - 1]} ${widget.secilenYil}';
    }
    final sirali = widget.secilenAylar.toList()..sort();
    return '${sirali.map((a) => _aylarKisa[a - 1]).join(', ')} ${widget.secilenYil}';
  }

  String get _subeBaslik {
    if (widget.secilenSubeler.isEmpty) return 'Tümü';
    if (widget.secilenSubeler.length == 1) {
      return widget.subeler[widget.secilenSubeler.first] ??
          widget.secilenSubeler.first;
    }
    return '${widget.secilenSubeler.length} Şube';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  void _ayToggle(int ay, bool v) {
    final yeni = Set<int>.from(widget.secilenAylar);
    final tumSecili = yeni.isEmpty || yeni.length == 12;
    if (tumSecili) {
      widget.onAylarDegisti(v ? {ay} : {});
      return;
    }
    if (v) {
      yeni.add(ay);
      if (yeni.length == 12) {
        widget.onAylarDegisti({});
      } else {
        widget.onAylarDegisti(yeni);
      }
    } else {
      yeni.remove(ay);
      widget.onAylarDegisti(yeni);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Dönem paneli ────────────────────────────────────────────────
            _panel(
              baslik: 'Dönem',
              deger: _donemBaslik,
              acik: _donemAcik,
              onToggle: () => setState(() => _donemAcik = !_donemAcik),
              icerik: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tarihAralikGoster) ...[
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'ay',
                            label: Text('Ay Seç'),
                            icon: Icon(Icons.calendar_month, size: 16)),
                        ButtonSegment(
                            value: 'aralik',
                            label: Text('Tarih Aralığı'),
                            icon: Icon(Icons.date_range, size: 16)),
                      ],
                      selected: {widget.filtreModu},
                      onSelectionChanged: (s) =>
                          widget.onFiltreModu(s.first),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (widget.filtreModu == 'ay') ...[
                    _yilChiplar(
                      secilen: widget.secilenYil,
                      renk: _anaRenk,
                      onSecildi: widget.onYilDegisti,
                    ),
                    const SizedBox(height: 8),
                    _ayChiplar(),
                  ] else ...[
                    _tarihSecici(
                      bas: widget.baslangic,
                      bit: widget.bitis,
                      onBas: widget.onBaslangicDegisti,
                      onBit: widget.onBitisDegisti,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Şube paneli ─────────────────────────────────────────────────
            if (widget.subeGoster && widget.subeler.isNotEmpty) ...[
              _panel(
                baslik: 'Şube',
                deger: _subeBaslik,
                acik: _subeAcik,
                onToggle: () => setState(() => _subeAcik = !_subeAcik),
                icerik: _subeChiplar(),
              ),
              const SizedBox(height: 8),
            ],

            // ── Ekstra filtre (kanal seçimi vb.) ────────────────────────────
            if (widget.ekstraFiltre != null) ...[
              widget.ekstraFiltre!,
              const SizedBox(height: 8),
            ],

            // ── Karşılaştırma ───────────────────────────────────────────────
            if (widget.karsilastirmaGoster) ...[
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Önceki Dönemle Karşılaştır',
                    style: TextStyle(fontSize: 13)),
                value: widget.karsilastirmaAcik,
                activeColor: _anaRenk,
                onChanged: widget.onKarsilastirmaToggle,
              ),
              if (widget.karsilastirmaAcik) ...[
                _panel(
                  baslik: 'Karş. Dönem',
                  deger: widget.filtreModu == 'aralik' &&
                          widget.karsilastirmaBaslangic != null
                      ? '${_pad(widget.karsilastirmaBaslangic!.day)}.${_pad(widget.karsilastirmaBaslangic!.month)}.${widget.karsilastirmaBaslangic!.year} – ${_pad(widget.karsilastirmaBitis!.day)}.${_pad(widget.karsilastirmaBitis!.month)}.${widget.karsilastirmaBitis!.year}'
                      : '${_aylarTam[widget.karsilastirmaAy - 1]} ${widget.karsilastirmaYil}',
                  acik: _karsDonemAcik,
                  renk: _karsRenk,
                  onToggle: () =>
                      setState(() => _karsDonemAcik = !_karsDonemAcik),
                  icerik: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (widget.filtreModu == 'ay') ...[
                        _yilChiplar(
                          secilen: widget.karsilastirmaYil,
                          renk: _karsRenk,
                          onSecildi: widget.onKarsilastirmaYilDegisti,
                        ),
                        const SizedBox(height: 8),
                        _karsAyChiplar(),
                      ] else if (widget.karsilastirmaBaslangic != null) ...[
                        _tarihSecici(
                          bas: widget.karsilastirmaBaslangic!,
                          bit: widget.karsilastirmaBitis!,
                          onBas: widget.onKarsilastirmaBaslangicDegisti,
                          onBit: widget.onKarsilastirmaBitisDegisti,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],

            // ── Göster butonu ───────────────────────────────────────────────
            FilledButton.icon(
              onPressed: widget.onGoster,
              icon: const Icon(Icons.search, size: 18),
              label: Text(widget.butonMetni),
              style: FilledButton.styleFrom(
                backgroundColor: _anaRenk,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Yardımcı widget'lar ───────────────────────────────────────────────────

  Widget _panel({
    required String baslik,
    required String deger,
    required bool acik,
    required VoidCallback onToggle,
    required Widget icerik,
    Color renk = _anaRenk,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(children: [
              Text(baslik,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(deger,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(acik ? Icons.expand_less : Icons.expand_more,
                  size: 18, color: Colors.black54),
            ]),
          ),
        ),
        if (acik)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: icerik,
          ),
      ],
    );
  }

  Widget _yilChiplar({
    required int secilen,
    required Color renk,
    required ValueChanged<int> onSecildi,
  }) {
    final now = DateTime.now().year;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (i) => now - 2 + i)
            .map((y) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('$y',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: secilen == y
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                              secilen == y ? renk : Colors.black87,
                        )),
                    selected: secilen == y,
                    onSelected: (_) => onSecildi(y),
                    selectedColor: renk.withOpacity(0.15),
                    checkmarkColor: renk,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _ayChiplar() {
    final tumSecili = widget.secilenAylar.isEmpty ||
        widget.secilenAylar.length == 12;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        FilterChip(
          label: const Text('Tümü',
              style: TextStyle(fontSize: 12)),
          selected: tumSecili,
          onSelected: (_) =>
              widget.onAylarDegisti(tumSecili ? {} : {}),
          selectedColor: _anaRenk.withOpacity(0.15),
          checkmarkColor: _anaRenk,
        ),
        ...List.generate(12, (i) {
          final ay = i + 1;
          final secili = tumSecili || widget.secilenAylar.contains(ay);
          return FilterChip(
            label: Text(_aylarKisa[i],
                style: const TextStyle(fontSize: 12)),
            selected: secili,
            onSelected: (v) => _ayToggle(ay, v),
            selectedColor: _anaRenk.withOpacity(0.15),
            checkmarkColor: _anaRenk,
          );
        }),
      ],
    );
  }

  Widget _karsAyChiplar() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(12, (i) {
        final ay = i + 1;
        return ChoiceChip(
          label: Text(_aylarKisa[i],
              style: const TextStyle(fontSize: 12)),
          selected: widget.karsilastirmaAy == ay,
          onSelected: (_) => widget.onKarsilastirmaAyDegisti(ay),
          selectedColor: _karsRenk.withOpacity(0.15),
          checkmarkColor: _karsRenk,
        );
      }),
    );
  }

  Widget _subeChiplar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          FilterChip(
            label: const Text('Tümü'),
            selected: widget.secilenSubeler.isEmpty,
            onSelected: (_) => widget.onSubelerDegisti({}),
            selectedColor: _anaRenk.withOpacity(0.15),
            checkmarkColor: _anaRenk,
          ),
          ...widget.subeler.entries.map((e) => FilterChip(
                label: Text(e.value),
                selected: widget.secilenSubeler.contains(e.key),
                onSelected: (v) {
                  final yeni = Set<String>.from(widget.secilenSubeler);
                  v ? yeni.add(e.key) : yeni.remove(e.key);
                  widget.onSubelerDegisti(yeni);
                },
                selectedColor: _anaRenk.withOpacity(0.15),
                checkmarkColor: _anaRenk,
              )),
        ],
      ),
    );
  }

  Widget _tarihSecici({
    required DateTime bas,
    required DateTime bit,
    required ValueChanged<DateTime> onBas,
    required ValueChanged<DateTime> onBit,
  }) {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () async {
            final p = await showDatePicker(
              context: context,
              initialDate: bas,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (p != null) onBas(p);
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
              '${_pad(bas.day)}.${_pad(bas.month)}.${bas.year}'),
        ),
      ),
      const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('—')),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () async {
            final p = await showDatePicker(
              context: context,
              initialDate: bit,
              firstDate: bas,
              lastDate: DateTime.now(),
            );
            if (p != null) onBit(p);
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
              '${_pad(bit.day)}.${_pad(bit.month)}.${bit.year}'),
        ),
      ),
    ]);
  }
}


