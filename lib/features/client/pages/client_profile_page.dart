import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/auth/models/client_profile_model.dart';
import 'package:otoport_mobile/features/auth/models/client_profile_update_request.dart';
import 'package:otoport_mobile/features/auth/services/client_profile_service.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final ClientProfileService _profileService = ClientProfileService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool marketingConsent = false;
  String? errorMessage;
  ClientProfileModel? profile;

  bool isDarkMode = true; // Varsayılan premium koyu mod

  // Renk Paleti
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _profileService.getMyProfile();
      if (!response.authenticated || response.profile == null) {
        setState(() {
          errorMessage = 'Kullanıcı doğrulanamadı.';
          isLoading = false;
        });
        return;
      }

      final p = response.profile!;
      firstNameController.text = p.firstName ?? '';
      lastNameController.text = p.lastName ?? '';
      phoneController.text = p.phone ?? '';
      birthDateController.text = p.birthDate ?? '';
      marketingConsent = p.marketingConsent;

      setState(() {
        profile = p;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Profil yüklenemedi: $e';
        isLoading = false;
      });
    }
  }

  Future<void> saveProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final birthDate = birthDateController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => errorMessage = 'Ad ve soyad zorunludur.');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final request = ClientProfileUpdateRequest(
        firstName: firstName,
        lastName: lastName,
        phone: phone.isEmpty ? null : phone,
        birthDate: birthDate.isEmpty ? null : birthDate,
        marketingConsent: marketingConsent,
      );

      final response = await _profileService.updateMyProfile(request);
      setState(() => profile = response.profile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi.')),
      );
    } catch (e) {
      setState(() => errorMessage = 'Güncelleme hatası: $e');
    } finally {
      if (!mounted) return;
      setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  // --- UI BİLEŞENLERİ ---

  Widget _buildFirsatLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: firAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: firAmber, width: 1.5),
      ),
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

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: firAmber, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mutedGray, size: 20),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: firAmber, width: 1.5)),
          ),
        ),
      ],
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
        onRefresh: loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Profil Başlığı ve Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: firAmber, width: 2)),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: firAmber.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, size: 50, color: firAmber),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
                      style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(profile?.email ?? '', style: const TextStyle(color: mutedGray, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Kartı
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (errorMessage != null) ...[
                    Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 16),
                  ],
                  _buildProfileTextField(controller: TextEditingController(text: profile?.email), label: 'E-posta (Değiştirilemez)', icon: Icons.alternate_email, enabled: false),
                  const SizedBox(height: 20),
                  _buildProfileTextField(controller: firstNameController, label: 'Ad', icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildProfileTextField(controller: lastNameController, label: 'Soyad', icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildProfileTextField(controller: phoneController, label: 'Telefon', icon: Icons.phone_android, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildProfileTextField(controller: birthDateController, label: 'Doğum Tarihi', icon: Icons.calendar_today_outlined),
                  const SizedBox(height: 12),

                  Theme(
                    data: ThemeData(unselectedWidgetColor: mutedGray),
                    child: CheckboxListTile(
                      value: marketingConsent,
                      onChanged: (val) => setState(() => marketingConsent = val ?? false),
                      title: const Text('Kampanya ve pazarlama iletileri almak istiyorum', style: TextStyle(color: mutedGray, fontSize: 12)),
                      activeColor: firAmber,
                      checkColor: Colors.black,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]),
                      boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          : const Text('PROFİLİ GÜNCELLE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(child: Text('© FIRSAT', style: TextStyle(color: mutedGray, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}