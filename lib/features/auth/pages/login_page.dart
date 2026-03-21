import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/network/dio_error_parser.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/models/login_request.dart';
import 'package:otoport_mobile/features/auth/pages/forgot_password_page.dart';
import 'package:otoport_mobile/features/auth/pages/register_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';

import '../../admin/pages/admin_home_page.dart';
import '../../client/pages/client_home_page.dart';
import '../../store/pages/store_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  bool isLoading = false;
  String? errorMessage;
  bool obscurePassword = true;
  bool isDarkMode = true; // Webdeki gibi varsayılan Dark Mode

  // CSS Renk Kodları ve Tasarım Parametreleri
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color mutedGray = Color(0xFF9AA3B2);

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'E-posta ve şifre zorunludur.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      if (response.accessToken.trim().isEmpty || response.refreshToken.trim().isEmpty) {
        throw Exception('Sunucu yetkilendirme anahtarı döndürmedi.');
      }

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken.trim(),
        refreshToken: response.refreshToken.trim(),
        role: response.role.trim(),
        userId: response.id.toString(),
      );

      final me = await _authService.meWithAccessToken(response.accessToken.trim());

      if (!me.authenticated || me.role == null || me.role!.trim().isEmpty) {
        await _tokenStorage.clearAll();
        if (!mounted) return;
        setState(() => errorMessage = 'Oturum doğrulanamadı.');
        return;
      }

      final role = me.role!.trim().toUpperCase().replaceFirst('ROLE_', '');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarılı. Rol: $role')),
      );

      if (role == 'CLIENT') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientHomePage(isGuest: false)));
        return;
      }
      if (role == 'STORE') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StoreHomePage()));
        return;
      }
      if (role == 'ADMIN') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
        return;
      }

      setState(() => errorMessage = 'Bilinmeyen rol: $role');
    } catch (e) {
      final parsed = DioErrorParser.parse(e);
      if (!mounted) return;
      setState(() => errorMessage = parsed.message);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> continueAsGuest() async {
    await _tokenStorage.clearAll();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientHomePage(isGuest: true)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : lightBg;
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Arka plan gradient efekti (CSS'deki radial-gradient yansıması)
          if (isDarkMode)
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: firAmber.withOpacity(0.08),
                ),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Üst Bar: Logo ve Tema Değiştirici
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFirsatLogo(),
                      _buildThemeToggle(),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Tekrar Hoş Geldiniz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Devam etmek için giriş yapın',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: mutedGray, fontSize: 14),
                            ),
                            const SizedBox(height: 32),

                            // Giriş Formu (Card)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildTextField(
                                    controller: emailController,
                                    label: 'E-posta Adresi',
                                    icon: Icons.alternate_email,
                                    isDark: isDarkMode,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: passwordController,
                                    label: 'Şifre',
                                    icon: Icons.lock_outline,
                                    isDark: isDarkMode,
                                    isPassword: true,
                                    obscureText: obscurePassword,
                                    onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: isLoading ? null : () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                                      },
                                      child: const Text('Şifremi Unuttum', style: TextStyle(color: firAmber, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  if (errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  const SizedBox(height: 10),
                                  _buildPrimaryButton(
                                    onPressed: isLoading ? null : login,
                                    text: 'Giriş Yap',
                                    isLoading: isLoading,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),


                            OutlinedButton(
                              onPressed: isLoading ? null : continueAsGuest,
                              style: OutlinedButton.styleFrom(
                                // Yazı rengi: Koyu modda amber, açık modda standart yazı rengi
                                foregroundColor: isDarkMode ? firAmber : textColor,
                                // Çerçeve rengi: Koyu modda amber, açık modda hafif gri
                                side: BorderSide(
                                    color: isDarkMode ? firAmber.withOpacity(0.8) : Colors.black12,
                                    width: 1.5
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                // Butonun içine çok hafif bir amber parlaması (sadece koyu modda)
                                backgroundColor: isDarkMode ? firAmber.withOpacity(0.03) : Colors.transparent,
                              ),
                              child: const Text(
                                  'Misafir Olarak Devam Et',
                                  style: TextStyle(fontWeight: FontWeight.w900) // Daha belirgin ve premium
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: isLoading ? null : () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Hesabın yok mu? ",
                                  style: TextStyle(color: mutedGray),
                                  children: const [
                                    TextSpan(text: "Kayıt Ol", style: TextStyle(color: firAmber, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('© FIRSAT', style: TextStyle(color: mutedGray, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Webdeki brand-ribbon tasarımının mobil uyarlaması
  Widget _buildFirsatLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: firAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: firAmber, width: 1.5),
      ),
      child: RichText(
        text: TextSpan(
          // Genel font stili
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900, // FontWeight.black syntax hatası vermez
            letterSpacing: 0.5,
          ),
          children: [
            // ✅ "FIR" kısmı: Koyu modda beyaz, Açık modda siyah
            TextSpan(
              text: "FIR",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            // "SAT" kısmı: Her zaman amber turuncu
            const TextSpan(
              text: "SAT",
              style: TextStyle(color: firAmber),
            ),
          ],
        ),
      ),
    );
  }

  // Webdeki tema anahtarı (Switch) uyarlaması
  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(4),
        width: 60,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: firAmber),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: firAmber)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mutedGray, size: 20),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: mutedGray, size: 20),
              onPressed: onToggleVisibility,
            )
                : null,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: firAmber, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required VoidCallback? onPressed, required String text, bool isLoading = false}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]),
        boxShadow: [
          BoxShadow(
            color: firAmber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}