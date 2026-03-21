import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otoport_mobile/core/network/dio_error_parser.dart';
import 'package:otoport_mobile/features/store/model/catalog_models.dart';
import 'package:otoport_mobile/features/store/model/expert_item_dto.dart';
import 'package:otoport_mobile/features/store/model/expert_report_dto.dart';
import 'package:otoport_mobile/features/store/model/store_listing_create_request.dart';
import 'package:otoport_mobile/features/store/service/store_create_listing_service.dart';

class StoreListingCreatePage extends StatefulWidget {
  const StoreListingCreatePage({super.key});

  @override
  State<StoreListingCreatePage> createState() => _StoreListingCreatePageState();
}

class _StoreListingCreatePageState extends State<StoreListingCreatePage> {
  // --- SERVISLER VE KEYLER ---
  final StoreCreateListingService _service = StoreCreateListingService();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- CONTROLLERLAR ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _engineCcController = TextEditingController();
  final TextEditingController _engineHpController = TextEditingController();

  // --- TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;
  String currency = 'TRY';
  bool negotiable = true;
  String catalogType = 'CAR';
  VehicleCatalogDto? catalog;
  String? selectedBrand;
  String? selectedModel;
  String? selectedVariant;
  String? selectedEngine;
  String? selectedPackage;
  String? transmission;
  String? fuelType;
  String? bodyType;
  final List<File> images = [];
  final Map<String, String> expertStates = {};
  final Map<String, String> expertNotes = {};
  String selectedExpertPart = 'HOOD';

  static const List<String> _allParts = [
    'HOOD', 'ROOF', 'FRONT_BUMPER', 'REAR_BUMPER', 'FRONT_LEFT_FENDER',
    'FRONT_RIGHT_FENDER', 'FRONT_LEFT_DOOR', 'FRONT_RIGHT_DOOR',
    'REAR_LEFT_DOOR', 'REAR_RIGHT_DOOR', 'REAR_LEFT_FENDER',
    'REAR_RIGHT_FENDER', 'TRUNK_LID', 'CHASSIS', 'PILLAR_LEFT', 'PILLAR_RIGHT',
  ];

  static const List<String> _expertStatuses = ['ORIGINAL', 'PAINTED', 'LOCAL_PAINT', 'REPLACED'];

  @override
  void initState() {
    super.initState();
    for (final part in _allParts) { expertStates[part] = 'ORIGINAL'; expertNotes[part] = ''; }
    _loadCatalog();
  }

  // --- MANTIK FONKSIYONLARI (EKSİKSİZ KORUNDU) ---
  Future<void> _loadCatalog() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _service.loadCatalog(catalogType);
      if (!mounted) return;
      setState(() { catalog = result; selectedBrand = null; selectedModel = null; selectedVariant = null; selectedEngine = null; selectedPackage = null; });
    } catch (e) {
      setState(() => errorMessage = DioErrorParser.parse(e).message);
    } finally { if (mounted) setState(() => isLoading = false); }
  }

  CatalogBrandDto? get _brandObj => catalog?.brands.firstWhere((b) => b.brand == selectedBrand, orElse: () => CatalogBrandDto(brand: '', models: []));
  CatalogModelDto? get _modelObj => _brandObj?.models.firstWhere((m) => m.model == selectedModel, orElse: () => CatalogModelDto(model: '', variants: [], engines: [], trims: []));
  CatalogVariantDto? get _variantObj => _modelObj?.variants.firstWhere((v) => v.variant == selectedVariant, orElse: () => CatalogVariantDto(variant: '', engines: [], packages: [], trims: []));

  List<String> get _brandNames => (catalog?.brands ?? []).map((e) => e.brand).where((e) => e.isNotEmpty).toList();
  List<String> get _modelNames => (_brandObj?.models ?? []).map((e) => e.model).where((e) => e.isNotEmpty).toList();
  List<String> get _variantNames => (_modelObj?.variants ?? []).map((e) => e.variant).where((e) => e.isNotEmpty).toList();

  List<String> get _engineNames {
    if (_variantObj != null && _variantObj!.engines.isNotEmpty) return _variantObj!.engines.map((e) => e.engine).toList();
    if (_modelObj != null && _modelObj!.engines.isNotEmpty) return _modelObj!.engines.map((e) => e.engine).toList();
    return [];
  }

  List<String> get _packageNames {
    if (_variantObj != null && _variantObj!.packages.isNotEmpty) return _variantObj!.packages;
    if (selectedEngine != null) {
      final engine = (_variantObj?.engines ?? _modelObj?.engines ?? []).firstWhere((e) => e.engine == selectedEngine, orElse: () => CatalogEngineDto(engine: '', packages: []));
      return engine.packages;
    }
    return [];
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      final incoming = picked.map((e) => File(e.path)).toList();
      images.addAll(incoming);
      if (images.length > 10) images.removeRange(10, images.length);
    });
  }

  void _reorderImages(int oldIdx, int newIdx) {
    setState(() { if (newIdx > oldIdx) newIdx -= 1; final item = images.removeAt(oldIdx); images.insert(newIdx, item); });
  }

  ExpertReportDto _buildExpertReport() {
    final items = expertStates.entries
        .where((e) => e.value != 'ORIGINAL')
        .map((e) => ExpertItemDto(
      part: e.key,
      status: e.value,
      note: expertNotes[e.key] ?? "",
    ))
        .toList();

    // Sonuç mantığını belirle
    String result = 'CLEAN';
    if (items.any((e) => e.status == 'REPLACED')) {
      result = 'MAJOR';
    } else if (items.isNotEmpty) {
      result = 'MINOR';
    }

    // Modelin beklediği tüm parametreleri eksiksiz gönderiyoruz
    return ExpertReportDto(
      id: null,
      carId: null,
      companyName: null,
      reportDate: null,
      reportNo: null,
      result: result,
      notes: null,
      items: items,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedBrand == null || selectedModel == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen marka ve model seçin.'))); return; }
    setState(() => isSubmitting = true);
    try {
      final request = StoreListingCreateRequest(
        title: _titleController.text.trim(), price: double.parse(_priceController.text.trim()), currency: currency,
        negotiable: negotiable, city: _cityController.text.trim(), district: _districtController.text.trim(),
        brand: selectedBrand!, model: selectedModel!, variant: selectedVariant, engine: selectedEngine, carPackage: selectedPackage,
        transmission: transmission!, fuelType: fuelType!, bodyType: bodyType!, year: int.parse(_yearController.text.trim()),
        kilometer: int.parse(_kmController.text.trim()), color: _colorController.text, description: _descriptionController.text,
        engineVolumeCc: int.tryParse(_engineCcController.text), enginePowerHp: int.tryParse(_engineHpController.text),
        expertReport: _buildExpertReport(),
      );
      final res = await _service.createListing(request: request, images: images);
      if (res.ok) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DioErrorParser.parse(e).message)));
    } finally { setState(() => isSubmitting = false); }
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

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        width: 50, height: 28, padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(15)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 22, height: 22, decoration: const BoxDecoration(shape: BoxShape.circle, color: firAmber), child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 14, color: Colors.black)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? darkCard : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _buildFirsatLogo(),
        actions: [_buildThemeToggle(), const SizedBox(width: 12)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Yeni İlan Oluştur'.toUpperCase(), style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Aracınızı sisteme eklemek için aşağıdaki adımları takip edin.', style: TextStyle(color: mutedGray, fontSize: 13)),
            const SizedBox(height: 24),

            _sectionHeader('1. TEMEL BİLGİLER', Icons.edit_note_rounded),
            _premiumCard(cardColor, _buildBasicInfoFields(textColor)),

            _sectionHeader('2. ARAÇ SEÇİMİ', Icons.directions_car_filled_rounded),
            _premiumCard(cardColor, _buildCatalogFields(textColor, cardColor)),

            _sectionHeader('3. TEKNİK DETAYLAR', Icons.settings_applications_rounded),
            _premiumCard(cardColor, _buildTechnicalFields(textColor, cardColor)),

            _sectionHeader('4. ARAÇ FOTOĞRAFLARI', Icons.add_a_photo_rounded),
            _premiumCard(cardColor, _buildImagePickerArea(textColor)),

            _sectionHeader('5. EKSPERTİZ RAPORU', Icons.fact_check_rounded),
            _premiumCard(cardColor, _buildExpertArea(textColor, cardColor)),

            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- FORM FIELDS ---

  Widget _buildBasicInfoFields(Color textColor) {
    return Column(children: [
      _premiumTextField(_titleController, 'İlan Başlığı', 'Örn: Hatasız Boyasız Audi A3', textColor, required: true),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(flex: 2, child: _premiumTextField(_priceController, 'Fiyat', '0', textColor, isNumber: true, required: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumDropdown<String>('Döviz', currency, ['TRY', 'USD', 'EUR'], (v) => setState(() => currency = v!), (v) => v, textColor, darkCard)),
      ]),
      const SizedBox(height: 16),
      _premiumTextField(_descriptionController, 'Açıklama', 'Araç hakkında detaylı bilgi...', textColor, maxLines: 4),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_cityController, 'Şehir', 'Örn: İstanbul', textColor, required: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_districtController, 'İlçe', 'Örn: Beşiktaş', textColor)),
      ]),
    ]);
  }

  Widget _buildCatalogFields(Color textColor, Color dropdownBg) {
    return Column(children: [
      _premiumDropdown<String>('Araç Tipi', catalogType, ['CAR', 'SUV', 'VAN'], (v) { setState(() => catalogType = v!); _loadCatalog(); }, (v) => v == 'CAR' ? 'Binek' : v, textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Marka', selectedBrand, _brandNames, (v) => setState(() { selectedBrand = v; selectedModel = null; }), (v) => v, textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Model', selectedModel, _modelNames, (v) => setState(() { selectedModel = v; selectedVariant = null; }), (v) => v, textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Varyant / Seri', selectedVariant, _variantNames, (v) => setState(() => selectedVariant = v), (v) => v, textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Motor / Donanım', selectedEngine, _engineNames, (v) => setState(() => selectedEngine = v), (v) => v, textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Paket', selectedPackage, _packageNames, (v) => setState(() => selectedPackage = v), (v) => v, textColor, dropdownBg),
    ]);
  }

  Widget _buildTechnicalFields(Color textColor, Color dropdownBg) {
    return Column(children: [
      Row(children: [
        Expanded(child: _premiumTextField(_yearController, 'Yıl', '2024', textColor, isNumber: true, required: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_kmController, 'Kilometre', '0', textColor, isNumber: true, required: true)),
      ]),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Vites Tipi', transmission, ['MANUAL', 'AUTOMATIC', 'SEMI_AUTOMATIC'], (v) => setState(() => transmission = v), (v) => v == 'MANUAL' ? 'Manuel' : 'Otomatik', textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Yakıt Tipi', fuelType, ['GASOLINE', 'DIESEL', 'HYBRID', 'ELECTRIC', 'LPG'], (v) => setState(() => fuelType = v), (v) => v, textColor, dropdownBg),
      const SizedBox(height: 16),
      _premiumDropdown<String>('Kasa Tipi', bodyType, ['SEDAN', 'HATCHBACK', 'SUV', 'COUPE', 'WAGON', 'VAN'], (v) => setState(() => bodyType = v), (v) => v, textColor, dropdownBg),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_engineCcController, 'Motor (cc)', '1600', textColor, isNumber: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_engineHpController, 'Güç (hp)', '110', textColor, isNumber: true)),
      ]),
    ]);
  }

  Widget _buildImagePickerArea(Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      OutlinedButton.icon(
        onPressed: images.length >= 10 ? null : _pickImages,
        icon: const Icon(Icons.add_photo_alternate_rounded, color: firAmber),
        label: Text('Fotoğraf Ekle (${images.length}/10)', style: const TextStyle(color: firAmber, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: firAmber), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      if (images.isNotEmpty) ...[
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            onReorder: _reorderImages,
            itemCount: images.length,
            itemBuilder: (ctx, idx) => _imageTile(idx, images[idx]),
          ),
        ),
      ]
    ]);
  }

  Widget _imageTile(int idx, File file) {
    return Container(
      key: ValueKey(file.path),
      width: 100, height: 100, margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: idx == 0 ? firAmber : Colors.white10, width: 2)),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(file, fit: BoxFit.cover, width: 100, height: 100)),
        if (idx == 0) Positioned(top: 4, left: 4, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(6)), child: const Text('KAPAK', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)))),
        Positioned(top: 0, right: 0, child: IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20), onPressed: () => setState(() => images.removeAt(idx)))),
      ]),
    );
  }

  Widget _buildExpertArea(Color textColor, Color dropdownBg) {
    return Column(children: [
      _expertSketch(),
      const SizedBox(height: 20),
      Text('SEÇİLİ PARÇA: ${_partLabel(selectedExpertPart).toUpperCase()}', style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12)),
      const SizedBox(height: 12),
      _premiumDropdown<String>('Parça Durumu', expertStates[selectedExpertPart], _expertStatuses, (v) => setState(() => expertStates[selectedExpertPart] = v!), (v) => _statusLabel(v), textColor, dropdownBg),
      const SizedBox(height: 12),
      if (expertStates[selectedExpertPart] != 'ORIGINAL') _premiumTextField(null, 'Ekspertiz Notu', 'Örn: Çizik kaynaklı lokal boya', textColor, onChanged: (v) => expertNotes[selectedExpertPart] = v, initialVal: expertNotes[selectedExpertPart]),
    ]);
  }

  // --- SKETCH HELPERS ---

  Widget _expertSketch() {
    return Container(
      height: 320, width: double.infinity,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Stack(alignment: Alignment.center, children: [
        // Car Silhouette
        Container(width: 140, height: 260, decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(40))),
        // Parts (Manual positions for clean UI)
        _partBox('FRONT_BUMPER', 110, 20, 110, 30),
        _partBox('HOOD', 115, 55, 100, 45),
        _partBox('FRONT_LEFT_FENDER', 50, 75, 55, 45),
        _partBox('FRONT_RIGHT_FENDER', 225, 75, 55, 45),
        _partBox('ROOF', 120, 105, 90, 60),
        _partBox('FRONT_LEFT_DOOR', 70, 130, 50, 70),
        _partBox('FRONT_RIGHT_DOOR', 210, 130, 50, 70),
        _partBox('REAR_LEFT_DOOR', 70, 205, 50, 70),
        _partBox('REAR_RIGHT_DOOR', 210, 205, 50, 70),
        _partBox('TRUNK_LID', 115, 245, 100, 45),
        _partBox('REAR_BUMPER', 110, 295, 110, 25),
      ]),
    );
  }

  Widget _partBox(String part, double left, double top, double w, double h) {
    final status = expertStates[part] ?? 'ORIGINAL';
    final isSelected = selectedExpertPart == part;
    return Positioned(
      left: left, top: top, width: w, height: h,
      child: GestureDetector(
        onTap: () => setState(() => selectedExpertPart = part),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _statusColor(status).withOpacity(isSelected ? 0.8 : 0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Center(child: Text(_partLabel(part), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(padding: const EdgeInsets.only(bottom: 12, top: 12), child: Row(children: [Icon(icon, color: firAmber, size: 18), const SizedBox(width: 8), Text(title, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1))]));
  }

  Widget _premiumCard(Color color, Widget child) {
    return Container(padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)), child: child);
  }

  Widget _premiumTextField(TextEditingController? ctrl, String label, String hint, Color txtColor, {bool isNumber = false, bool required = false, int maxLines = 1, Function(String)? onChanged, String? initialVal}) {
    return TextFormField(
      controller: ctrl, initialValue: initialVal, maxLines: maxLines, onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: txtColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 12),
        hintText: hint, hintStyle: TextStyle(color: mutedGray.withOpacity(0.5)),
        filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Zorunlu alan' : null : null,
    );
  }

  Widget _premiumDropdown<T>(String label, T? val, List<T> items, Function(T?) onChg, String Function(T) labelB, Color txtColor, Color bg) {
    return DropdownButtonFormField<T>(
      value: items.contains(val) ? val : null,
      dropdownColor: bg,
      style: TextStyle(color: txtColor, fontSize: 14),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 12), filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelB(e)))).toList(),
      onChanged: onChg,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]), boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: isSubmitting
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text('İLANIMI YAYINLA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
      ),
    );
  }

  // --- HELPERS ---
  String _partLabel(String p) => {'HOOD':'Kaput','ROOF':'Tavan','FRONT_BUMPER':'Ön Tampon','REAR_BUMPER':'Arka Tampon','FRONT_LEFT_FENDER':'Sol Ön Çamurluk','FRONT_RIGHT_FENDER':'Sağ Ön Çamurluk','FRONT_LEFT_DOOR':'Sol Ön Kapı','FRONT_RIGHT_DOOR':'Sağ Ön Kapı','REAR_LEFT_DOOR':'Sol Arka Kapı','REAR_RIGHT_DOOR':'Sağ Arka Kapı','REAR_LEFT_FENDER':'Sol Arka Çamurluk','REAR_RIGHT_FENDER':'Sağ Arka Çamurluk','TRUNK_LID':'Bagaj Kapağı','CHASSIS':'Şasi','PILLAR_LEFT':'Sol Direk','PILLAR_RIGHT':'Sağ Direk'}[p] ?? p;
  String _statusLabel(String v) => {'ORIGINAL':'Orijinal','PAINTED':'Boyalı','LOCAL_PAINT':'Lokal Boya','REPLACED':'Değişen'}[v] ?? v;
  Color _statusColor(String v) => v == 'PAINTED' ? Colors.blue : (v == 'LOCAL_PAINT' ? Colors.orange : (v == 'REPLACED' ? Colors.red : Colors.green));

  @override void dispose() { _titleController.dispose(); _priceController.dispose(); _descriptionController.dispose(); _cityController.dispose(); _districtController.dispose(); _yearController.dispose(); _kmController.dispose(); _colorController.dispose(); _engineCcController.dispose(); _engineHpController.dispose(); super.dispose(); }
}