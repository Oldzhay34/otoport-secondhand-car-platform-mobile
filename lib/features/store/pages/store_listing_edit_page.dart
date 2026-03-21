import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/store/model/expert_item_dto.dart';
import 'package:otoport_mobile/features/store/model/expert_report_dto.dart';
import 'package:otoport_mobile/features/store/model/store_car_update_request.dart';
import 'package:otoport_mobile/features/store/model/store_listing_edit_dto.dart';
import '../service/store_listing_management_service.dart';

class StoreListingEditPage extends StatefulWidget {
  final int listingId;
  const StoreListingEditPage({super.key, required this.listingId});

  @override
  State<StoreListingEditPage> createState() => _StoreListingEditPageState();
}

class _StoreListingEditPageState extends State<StoreListingEditPage> {
  final StoreListingManagementService _service = StoreListingManagementService();

  // --- CONTROLLERLAR ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(text: 'TRY');
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _kilometerController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _engineVolumeCcController = TextEditingController();
  final TextEditingController _enginePowerHpController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool negotiable = false;
  bool isLoading = true;
  bool isSaving = false;
  bool isDeleting = false;
  String? errorMessage;
  int? carId;
  Map<String, String> expertState = {};

  static const List<String> allParts = [
    'HOOD', 'ROOF', 'FRONT_BUMPER', 'REAR_BUMPER', 'FRONT_LEFT_FENDER',
    'FRONT_RIGHT_FENDER', 'FRONT_LEFT_DOOR', 'FRONT_RIGHT_DOOR',
    'REAR_LEFT_DOOR', 'REAR_RIGHT_DOOR', 'REAR_LEFT_FENDER',
    'REAR_RIGHT_FENDER', 'TRUNK_LID',
  ];

  static const List<String> statusCycle = ['ORIGINAL', 'PAINTED', 'LOCAL_PAINT', 'REPLACED'];
  String selectedPart = allParts.first;
  String selectedStatus = 'ORIGINAL';

  @override
  void initState() {
    super.initState();
    for (final part in allParts) { expertState[part] = 'ORIGINAL'; }
    _loadPage();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _loadPage() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = await _service.getForEdit(widget.listingId);
      _fillForm(data);
    } catch (e) {
      setState(() => errorMessage = 'İlan verileri yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _fillForm(StoreListingEditDto data) {
    _titleController.text = data.title;
    _descriptionController.text = data.description;
    _priceController.text = data.price?.toString() ?? '';
    _currencyController.text = data.currency.isEmpty ? 'TRY' : data.currency;
    _cityController.text = data.city;
    _districtController.text = data.district;
    _yearController.text = data.year?.toString() ?? '';
    _kilometerController.text = data.kilometer?.toString() ?? '';
    _colorController.text = data.color;
    _engineVolumeCcController.text = data.engineVolumeCc?.toString() ?? '';
    _enginePowerHpController.text = data.enginePowerHp?.toString() ?? '';
    negotiable = data.negotiable;
    carId = data.carId;

    for (final part in allParts) { expertState[part] = 'ORIGINAL'; }
    final items = data.expertReport?.items ?? [];
    for (final item in items) {
      final p = (item.part ?? '').trim().toUpperCase();
      final s = (item.status ?? '').trim().toUpperCase();
      if (allParts.contains(p) && statusCycle.contains(s)) { expertState[p] = s; }
    }
    selectedStatus = expertState[selectedPart] ?? 'ORIGINAL';
  }

  StoreCarUpdateRequest _buildPayload() {
    final expertItems = <ExpertItemDto>[];
    expertState.forEach((part, status) {
      if (status != 'ORIGINAL') { expertItems.add(ExpertItemDto(part: part, status: status, note: "Güncellendi")); }
    });

    String result = 'CLEAN';
    if (expertItems.any((e) => e.status == 'REPLACED')) { result = 'MAJOR'; }
    else if (expertItems.isNotEmpty) { result = 'MINOR'; }

    return StoreCarUpdateRequest(
      title: _titleController.text.trim(), description: _descriptionController.text,
      price: double.tryParse(_priceController.text), currency: _currencyController.text.toUpperCase(),
      negotiable: negotiable, city: _cityController.text, district: _districtController.text,
      year: int.tryParse(_yearController.text), kilometer: int.tryParse(_kilometerController.text),
      color: _colorController.text, engineVolumeCc: int.tryParse(_engineVolumeCcController.text),
      enginePowerHp: int.tryParse(_enginePowerHpController.text),
      expertReport: ExpertReportDto(id: null, carId: carId, companyName: null, reportDate: null, reportNo: null, result: result, notes: null, items: expertItems),
    );
  }

  Future<void> _save() async {
    setState(() => isSaving = true);
    try {
      await _service.update(widget.listingId, _buildPayload());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan başarıyla güncellendi.')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Güncelleme sırasında hata oluştu.')));
    } finally { if (mounted) setState(() => isSaving = false); }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text('İlanı Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Bu ilanı kalıcı olarak silmek istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ', style: TextStyle(color: mutedGray))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('SİL', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => isDeleting = true);
    try {
      final ok = await _service.delete(widget.listingId);
      if (ok && mounted) Navigator.pop(context, true);
    } finally { if (mounted) setState(() => isDeleting = false); }
  }

  // --- UI BUILDERS ---

  Widget _buildFirsatLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: firAmber, width: 1.5)),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          children: [
            TextSpan(text: "FIR", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            const TextSpan(text: "SAT", style: TextStyle(color: firAmber)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _buildFirsatLogo(),
        actions: [
          IconButton(icon: Icon(Icons.delete_outline_rounded, color: isDeleting ? mutedGray : Colors.redAccent), onPressed: isDeleting ? null : _delete),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('İlanı Güncelle'.toUpperCase(), style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Aşağıdaki alanları revize ederek ilanınızı güncel tutun.', style: TextStyle(color: mutedGray, fontSize: 13)),
          const SizedBox(height: 24),

          _sectionHeader('1. İLAN DETAYLARI', Icons.description_rounded),
          _premiumCard(cardColor, _buildListingFields(textColor)),

          _sectionHeader('2. ARAÇ ÖZELLİKLERİ', Icons.settings_rounded),
          _premiumCard(cardColor, _buildCarFields(textColor)),

          _sectionHeader('3. EKSPERTİZ REVİZYONU', Icons.fact_check_rounded),
          _premiumCard(cardColor, _buildExpertFields(textColor, cardColor)),

          const SizedBox(height: 32),
          _buildSaveButton(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildListingFields(Color textColor) {
    return Column(children: [
      _premiumTextField(_titleController, 'Başlık', 'İlan başlığını girin', textColor),
      const SizedBox(height: 16),
      _premiumTextField(_descriptionController, 'Açıklama', 'İlan açıklaması...', textColor, maxLines: 4),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(flex: 2, child: _premiumTextField(_priceController, 'Fiyat', '0', textColor, isNumber: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_currencyController, 'Döviz', 'TRY', textColor)),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_cityController, 'Şehir', 'Şehir', textColor)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_districtController, 'İlçe', 'İlçe', textColor)),
      ]),
      const SizedBox(height: 12),
      SwitchListTile(
        title: Text('Pazarlık Payı Var', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
        value: negotiable,
        activeColor: firAmber,
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => negotiable = v),
      ),
    ]);
  }

  Widget _buildCarFields(Color textColor) {
    return Column(children: [
      Row(children: [
        Expanded(child: _premiumTextField(_yearController, 'Yıl', '2024', textColor, isNumber: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_kilometerController, 'Kilometre', '0', textColor, isNumber: true)),
      ]),
      const SizedBox(height: 16),
      _premiumTextField(_colorController, 'Renk', 'Araç rengi', textColor),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_engineVolumeCcController, 'Motor (cc)', '1600', textColor, isNumber: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_enginePowerHpController, 'Güç (hp)', '110', textColor, isNumber: true)),
      ]),
    ]);
  }

  Widget _buildExpertFields(Color textColor, Color dropdownBg) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PARÇA SEÇİMİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
      const SizedBox(height: 12),
      _premiumDropdown<String>(selectedPart, allParts, (v) {
        setState(() { selectedPart = v!; selectedStatus = expertState[selectedPart] ?? 'ORIGINAL'; });
      }, (v) => _trPartName(v), textColor, dropdownBg),
      const SizedBox(height: 16),
      Text('DURUM ATAMA', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _premiumDropdown<String>(selectedStatus, statusCycle, (v) => setState(() => selectedStatus = v!), (v) => _trStatusName(v), textColor, dropdownBg)),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => setState(() => expertState[selectedPart] = selectedStatus),
          style: ElevatedButton.styleFrom(backgroundColor: firAmber, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(80, 52)),
          child: const Text('UYGULA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10)),
      Text('GÜNCEL DURUM ÖZETİ', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13)),
      const SizedBox(height: 12),
      ...expertState.entries.where((e) => e.value != 'ORIGINAL').map((e) => _expertSummaryTile(e.key, e.value, textColor)),
      if (expertState.values.every((v) => v == 'ORIGINAL')) const Center(child: Text('Tüm parçalar orijinal işaretlendi.', style: TextStyle(color: mutedGray, fontSize: 12))),
    ]);
  }

  Widget _expertSummaryTile(String part, String status, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: _statusColor(status).withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_trPartName(part), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
        _statusBadge(status),
      ]),
    );
  }

  // --- HELPERS ---

  Widget _sectionHeader(String t, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 16), child: Row(children: [Icon(i, color: firAmber, size: 18), const SizedBox(width: 8), Text(t, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))]));

  Widget _premiumCard(Color c, Widget ch) => Container(padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)), child: ch);

  Widget _premiumTextField(TextEditingController ctrl, String label, String hint, Color txtColor, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: txtColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 12),
        hintText: hint, hintStyle: TextStyle(color: mutedGray.withOpacity(0.5)),
        filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _premiumDropdown<T>(T val, List<T> items, Function(T?) onChg, String Function(T) labelB, Color txtColor, Color bg) {
    return DropdownButtonFormField<T>(
      value: items.contains(val) ? val : null,
      dropdownColor: bg,
      style: TextStyle(color: txtColor, fontSize: 14),
      decoration: InputDecoration(filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelB(e)))).toList(),
      onChanged: onChg,
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(_trStatusName(status).toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 56, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]), boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        onPressed: isSaving ? null : _save,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text('DEĞİŞİKLİKLERİ KAYDET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
      ),
    );
  }

  String _trPartName(String p) => {'HOOD':'Kaput','ROOF':'Tavan','FRONT_BUMPER':'Ön Tampon','REAR_BUMPER':'Arka Tampon','FRONT_LEFT_FENDER':'Sol Ön Çamurluk','FRONT_RIGHT_FENDER':'Sağ Ön Çamurluk','FRONT_LEFT_DOOR':'Sol Ön Kapı','FRONT_RIGHT_DOOR':'Sağ Ön Kapı','REAR_LEFT_DOOR':'Sol Arka Kapı','REAR_RIGHT_DOOR':'Sağ Arka Kapı','REAR_LEFT_FENDER':'Sol Arka Çamurluk','REAR_RIGHT_FENDER':'Sağ Arka Çamurluk','TRUNK_LID':'Bagaj'}[p] ?? p;
  String _trStatusName(String s) => {'ORIGINAL':'Orijinal','PAINTED':'Boyalı','LOCAL_PAINT':'Lokal Boya','REPLACED':'Değişen'}[s] ?? s;
  Color _statusColor(String s) => s == 'REPLACED' ? Colors.red : (s == 'PAINTED' ? Colors.blue : (s == 'LOCAL_PAINT' ? Colors.orange : Colors.green));

  @override void dispose() { _titleController.dispose(); _descriptionController.dispose(); _priceController.dispose(); _currencyController.dispose(); _cityController.dispose(); _districtController.dispose(); _yearController.dispose(); _kilometerController.dispose(); _colorController.dispose(); _engineVolumeCcController.dispose(); _enginePowerHpController.dispose(); super.dispose(); }
}