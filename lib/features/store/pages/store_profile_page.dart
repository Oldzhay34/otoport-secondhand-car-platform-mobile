import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otoport_mobile/core/network/dio_error_parser.dart';
import 'package:otoport_mobile/features/store/model/store_change_password_request.dart';
import 'package:otoport_mobile/features/store/model/store_my_profile_dto.dart';
import 'package:otoport_mobile/features/store/model/store_my_profile_update_request.dart';
import 'package:otoport_mobile/features/store/service/store_profile_service.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

class StoreProfilePage extends StatefulWidget {
  const StoreProfilePage({super.key});

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  final StoreProfileService _service = StoreProfileService();
  final ImagePicker _picker = ImagePicker();

  // --- CONTROLLERLAR ---
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _authorizedPersonController = TextEditingController();
  final TextEditingController _taxNoController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _shopNoController = TextEditingController();
  final TextEditingController _directionNoteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingLogo = false;
  bool isChangingPassword = false;
  String? errorMessage;
  StoreMyProfileDto? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _loadProfile() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _service.getMyProfile();
      if (!mounted) return;
      _fillControllers(result);
      setState(() { profile = result; });
    } catch (e) {
      setState(() => errorMessage = DioErrorParser.parse(e).message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _fillControllers(StoreMyProfileDto data) {
    _storeNameController.text = data.storeName;
    _authorizedPersonController.text = data.authorizedPerson;
    _taxNoController.text = data.taxNo;
    _websiteController.text = data.website;
    _cityController.text = data.city;
    _districtController.text = data.district;
    _addressLineController.text = data.addressLine;
    _floorController.text = data.floor;
    _shopNoController.text = data.shopNo;
    _directionNoteController.text = data.directionNote;
    _phoneController.text = data.phone;
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    try {
      final req = StoreMyProfileUpdateRequest(
        storeName: _storeNameController.text.trim(),
        authorizedPerson: _authorizedPersonController.text.trim(),
        taxNo: _taxNoController.text.trim(),
        website: _websiteController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        floor: _floorController.text.trim(),
        shopNo: _shopNoController.text.trim(),
        directionNote: _directionNoteController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      final updated = await _service.updateProfile(req);
      setState(() => profile = updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla güncellendi.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DioErrorParser.parse(e).message)));
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    final oldP = _oldPasswordController.text.trim();
    final newP = _newPasswordController.text.trim();
    final confP = _confirmPasswordController.text.trim();
    if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm alanları doldurun.')));
      return;
    }
    if (newP != confP) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni şifreler uyuşmuyor.')));
      return;
    }
    setState(() => isChangingPassword = true);
    try {
      await _service.changePassword(StoreChangePasswordRequest(oldPassword: oldP, newPassword: newP, confirmPassword: confP));
      _oldPasswordController.clear(); _newPasswordController.clear(); _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şifreniz değiştirildi.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DioErrorParser.parse(e).message)));
    } finally {
      setState(() => isChangingPassword = false);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      setState(() => isUploadingLogo = true);
      final response = await _service.uploadLogo(File(picked.path));
      if (!mounted) return;
      _loadProfile(); // Profili tekrar yükle ki logo güncellensin
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo başarıyla güncellendi.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DioErrorParser.parse(e).message)));
    } finally {
      setState(() => isUploadingLogo = false);
    }
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
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

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
          : RefreshIndicator(
        onRefresh: _loadProfile,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBusinessIdentityCard(cardColor, textColor),
            const SizedBox(height: 24),

            _sectionHeader('KURUMSAL BİLGİLER', Icons.business_center_rounded),
            _premiumCard(cardColor, _buildProfileForm(textColor)),

            const SizedBox(height: 24),
            _sectionHeader('GÜVENLİK AYARLARI', Icons.shield_rounded),
            _premiumCard(cardColor, _buildPasswordForm(textColor)),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessIdentityCard(Color cardColor, Color textColor) {
    final imageUrl = _normalizeImageUrl(profile?.logoUrl);
    final hasRealLogo = !(profile?.logoUrl == null || profile!.logoUrl!.trim().isEmpty);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (hasRealLogo)
                ClipOval(
                  child: Opacity(
                    opacity: 0.10,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Image.network(
                        imageUrl,
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _openImagePreview(imageUrl),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: firAmber, width: 2),
                    color: isDarkMode
                        ? Colors.black26
                        : Colors.black.withOpacity(0.03),
                  ),
                  child: ClipOval(
                    child: hasRealLogo
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.storefront_rounded,
                        size: 40,
                        color: firAmber,
                      ),
                    )
                        : const Icon(
                      Icons.storefront_rounded,
                      size: 40,
                      color: firAmber,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: MediaQuery.of(context).size.width > 400 ? 110 : 90,
                child: GestureDetector(
                  onTap: isUploadingLogo ? null : _pickAndUploadLogo,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: firAmber,
                      shape: BoxShape.circle,
                    ),
                    child: isUploadingLogo
                        ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile?.storeName ?? 'Mağaza Adı',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statusBadge(profile?.verified == true),
              const SizedBox(width: 12),
              _limitBadge(profile?.listingLimit ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(Color textColor) {
    return Column(children: [
      _premiumTextField(_storeNameController, 'Mağaza Adı', 'İşletme ismi', textColor),
      const SizedBox(height: 16),
      _premiumTextField(_authorizedPersonController, 'Yetkili Kişi', 'Ad Soyad', textColor),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_taxNoController, 'Vergi / TC No', '0000000000', textColor, isNumber: true)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_phoneController, 'İletişim No', '0555...', textColor, isNumber: true)),
      ]),
      const SizedBox(height: 16),
      _premiumTextField(_websiteController, 'Web Sitesi', 'www.ornek.com', textColor),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_cityController, 'Şehir', 'Şehir', textColor)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_districtController, 'İlçe', 'İlçe', textColor)),
      ]),
      const SizedBox(height: 16),
      _premiumTextField(_addressLineController, 'Açık Adres', 'Mahalle, sokak...', textColor, maxLines: 2),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _premiumTextField(_floorController, 'Kat', '0', textColor)),
        const SizedBox(width: 12),
        Expanded(child: _premiumTextField(_shopNoController, 'Dükkan No', '0', textColor)),
      ]),
      const SizedBox(height: 16),
      _premiumTextField(_directionNoteController, 'Yol Tarifi / Not', 'Mağazayı bulmayı kolaylaştırın...', textColor, maxLines: 2),
      const SizedBox(height: 24),
      _buildActionBtn('PROFİLİ GÜNCELLE', isSaving ? null : _saveProfile, isSaving),
    ]);
  }

  Widget _buildPasswordForm(Color textColor) {
    return Column(children: [
      _premiumTextField(_oldPasswordController, 'Mevcut Şifre', '••••••', textColor),
      const SizedBox(height: 16),
      _premiumTextField(_newPasswordController, 'Yeni Şifre', '••••••', textColor),
      const SizedBox(height: 16),
      _premiumTextField(_confirmPasswordController, 'Şifre Tekrar', '••••••', textColor),
      const SizedBox(height: 24),
      _buildActionBtn('ŞİFREYİ DEĞİŞTİR', isChangingPassword ? null : _changePassword, isChangingPassword),
    ]);
  }

  // --- HELPERS ---

  Widget _sectionHeader(String t, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 8), child: Row(children: [Icon(i, color: firAmber, size: 18), const SizedBox(width: 8), Text(t, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))]));

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

  Widget _buildActionBtn(String txt, VoidCallback? onTap, bool loading) {
    return Container(
      height: 52, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]), boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(txt, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _statusBadge(bool verified) {
    final color = verified ? Colors.blueAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(verified ? Icons.verified_rounded : Icons.info_outline_rounded, color: color, size: 12),
        const SizedBox(width: 4),
        Text(verified ? 'ONAYLI' : 'ONAY BEKLİYOR', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _limitBadge(int limit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: firAmber.withOpacity(0.3))),
      child: Text('LİMİT: $limit İLAN', style: const TextStyle(color: firAmber, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  String _normalizeImageUrl(String? path) {
    return ImageService.withFallback(path);
  }

  @override void dispose() {
    _storeNameController.dispose(); _authorizedPersonController.dispose(); _taxNoController.dispose(); _websiteController.dispose();
    _cityController.dispose(); _districtController.dispose(); _addressLineController.dispose(); _floorController.dispose();
    _shopNoController.dispose(); _directionNoteController.dispose(); _phoneController.dispose(); _oldPasswordController.dispose();
    _newPasswordController.dispose(); _confirmPasswordController.dispose(); super.dispose();
  }
  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}