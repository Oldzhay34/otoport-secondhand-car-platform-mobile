import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_create_store_account_request.dart';
import 'package:otoport_mobile/features/admin/models/admin_create_store_account_response.dart';
import 'package:otoport_mobile/features/admin/service/admin_store_account_service.dart';
import 'package:otoport_mobile/features/admin/widgets/admin_bottom_nav_bar.dart';

class AdminStoreAccountCreatePage extends StatefulWidget {
  const AdminStoreAccountCreatePage({super.key});

  @override
  State<AdminStoreAccountCreatePage> createState() => _AdminStoreAccountCreatePageState();
}

class _AdminStoreAccountCreatePageState extends State<AdminStoreAccountCreatePage> {
  final AdminStoreAccountService _service = AdminStoreAccountService();
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERLAR ---
  final TextEditingController _buildingIdController = TextEditingController();
  final TextEditingController _emailLocalPartController = TextEditingController(); // Yeni
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopNoController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _authorizedPersonController = TextEditingController();
  final TextEditingController _taxNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  bool isSaving = false;
  bool verified = false;
  AdminCreateStoreAccountResponse? created;

  @override
  void initState() {
    super.initState();
    // Email önizlemesini tetiklemek için listenerlar
    _emailLocalPartController.addListener(_onEmailInputChanged);
    _buildingIdController.addListener(() => setState(() {}));
  }

  void _onEmailInputChanged() {
    final text = _emailLocalPartController.text;
    final sanitized = text.replaceAll(RegExp(r'\s+'), '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    if (text != sanitized) {
      _emailLocalPartController.value = _emailLocalPartController.value.copyWith(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }
    setState(() {});
  }

  String _getPreviewEmail() {
    final lp = _emailLocalPartController.text.trim();
    if (lp.isEmpty) return "—";
    final bid = int.tryParse(_buildingIdController.text.trim()) ?? 1;
    final domain = (bid % 2 == 0) ? "autopia.com" : "otoport.com";
    return "$lp@$domain";
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    try {
      final response = await _service.createStore(
        AdminCreateStoreAccountRequest(
          buildingId: int.parse(_buildingIdController.text.trim()),
          storeName: _storeNameController.text.trim(),
          password: _passwordController.text.trim(),
          // E-posta local part backend'e bu şekilde gönderilir (gerekirse birleştirilip tam email de gönderilebilir)
          // email: _getPreviewEmail(),
          city: _optional(_cityController.text),
          district: _optional(_districtController.text),
          phone: _optional(_phoneController.text),
          shopNo: _optional(_shopNoController.text),
          floor: _optionalInt(_floorController.text),
          addressLine: _optional(_addressLineController.text),
          website: _optional(_websiteController.text),
          authorizedPerson: _optional(_authorizedPersonController.text),
          taxNo: _optional(_taxNoController.text),
          verified: verified,
        ),
      );

      setState(() { created = response; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mağaza hesabı başarıyla oluşturuldu.')));
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _buildingIdController.clear(); _emailLocalPartController.clear(); _storeNameController.clear();
    _passwordController.clear();
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: firAmber.withOpacity(0.3))),
            child: const Center(child: Text('ADMIN', style: TextStyle(color: firAmber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
          ),
          IconButton(icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: firAmber), onPressed: () => setState(() => isDarkMode = !isDarkMode)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroHeader(textColor),
          const SizedBox(height: 20),
          if (created != null) _buildResultCard(cardColor, textColor),
          _buildEmailPreviewBox(cardColor, textColor),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                _sectionHeader('1. TEMEL VE GÜVENLİK BİLGİLERİ'),
                _premiumCard(cardColor, Column(children: [
                  _premiumTextField(_storeNameController, 'Mağaza Adı', 'Örn: Fırsat Oto Galeri', textColor, required: true),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _premiumTextField(_buildingIdController, 'Building ID', 'Örn: 12', textColor, isNumber: true, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _premiumTextField(_emailLocalPartController, 'Email Local-Part', 'Örn: galeri.b24', textColor, required: true)),
                  ]),
                  const SizedBox(height: 16),
                  _premiumTextField(_passwordController, 'Şifre', '••••••••', textColor, required: true, isPassword: true),
                ])),

                _sectionHeader('2. KONUM VE İLETİŞİM'),
                _premiumCard(cardColor, Column(children: [
                  Row(children: [
                    Expanded(child: _premiumTextField(_cityController, 'Şehir', 'İstanbul', textColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _premiumTextField(_districtController, 'İlçe', 'Ataşehir', textColor)),
                  ]),
                  const SizedBox(height: 16),
                  _premiumTextField(_addressLineController, 'Açık Adres', 'Mahalle, Sokak No...', textColor, maxLines: 2),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _premiumTextField(_floorController, 'Kat', '2', textColor, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _premiumTextField(_shopNoController, 'Dükkan No', 'B-24', textColor)),
                  ]),
                  const SizedBox(height: 16),
                  _premiumTextField(_phoneController, 'Telefon', '05XX...', textColor),
                ])),

                _sectionHeader('3. DİĞER DETAYLAR'),
                _premiumCard(cardColor, Column(children: [
                  _premiumTextField(_authorizedPersonController, 'Yetkili Kişi', 'Ad Soyad', textColor),
                  const SizedBox(height: 16),
                  _premiumTextField(_taxNoController, 'Vergi No', '1234...', textColor),
                  const SizedBox(height: 16),
                  _premiumTextField(_websiteController, 'Web Sitesi', 'https://...', textColor),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('Mağaza Onaylı (Verified)', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Oluşturulduğunda direkt onaylı statüsünde olur.', style: TextStyle(color: mutedGray, fontSize: 11)),
                    activeColor: firAmber,
                    value: verified,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => verified = v),
                  ),
                ])),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 50),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeroHeader(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mağaza Hesabı Oluştur'.toUpperCase(), style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Yeni iş ortaklarımızı sisteme dahil edin.', style: TextStyle(color: mutedGray, fontSize: 13)),
      ],
    );
  }

  Widget _buildEmailPreviewBox(Color cardColor, Color textColor) {
    final preview = _getPreviewEmail();
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: firAmber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: firAmber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OLUŞACAK KURUMSAL E-POSTA', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.alternate_email_rounded, color: firAmber, size: 20),
              const SizedBox(width: 12),
              Text(preview, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Domain seçimi Building ID\'ye göre (Tek/Çift) otomatik yapılır.', style: TextStyle(color: mutedGray, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildResultCard(Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✓ BAŞARIYLA OLUŞTURULDU', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 11)),
        const SizedBox(height: 8),
        Text('Mağaza: ${created?.storeName}', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
        Text('Sistem ID: #${created?.storeId}', style: const TextStyle(color: mutedGray, fontSize: 12)),
      ]),
    );
  }

  // --- HELPERS ---

  Widget _sectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(title, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)));
  }

  Widget _premiumCard(Color c, Widget ch) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)), child: ch);

  Widget _premiumTextField(TextEditingController ctrl, String label, String hint, Color txtColor, {bool isNumber = false, bool required = false, bool isPassword = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines, obscureText: isPassword,
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

  Widget _buildSubmitButton() {
    return Container(
      height: 56, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]), boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : _submit,
        icon: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.add_business_rounded, color: Colors.black),
        label: Text(isSaving ? 'OLUŞTURULUYOR...' : 'MAĞAZA HESABINI AKTİFLEŞTİR', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }

  String? _optional(String t) => t.trim().isEmpty ? null : t.trim();
  int? _optionalInt(String t) => int.tryParse(t.trim());

  @override void dispose() {
    _buildingIdController.dispose(); _emailLocalPartController.dispose(); _storeNameController.dispose();
    _cityController.dispose(); _districtController.dispose(); _phoneController.dispose();
    _shopNoController.dispose(); _floorController.dispose(); _addressLineController.dispose();
    _websiteController.dispose(); _authorizedPersonController.dispose(); _taxNoController.dispose();
    _passwordController.dispose(); super.dispose();
  }
}