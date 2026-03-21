import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/network/dio_error_parser.dart';
import 'package:otoport_mobile/features/auth/models/forgot_password_request.dart';
import 'package:otoport_mobile/features/auth/models/reset_password_request.dart';
import 'package:otoport_mobile/features/auth/models/verify_reset_code_request.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordAgainController = TextEditingController();

  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _isResettingPassword = false;

  bool _codeSent = false;
  bool _codeVerified = false;

  String? _resetToken;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscurePasswordAgain = true;
  bool isDarkMode = true; // Varsayılan premium koyu mod

  // CSS Renk Kodları
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color mutedGray = Color(0xFF9AA3B2);

  int _nowTs() => DateTime.now().millisecondsSinceEpoch;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'E-posta zorunludur.');
      return;
    }

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPassword(
        ForgotPasswordRequest(
          email: email,
          hp: '',
          clientTs: _nowTs() - 1200,
        ),
      );

      if (!mounted) return;
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doğrulama kodu gönderildi.')));
    } catch (e) {
      final parsed = DioErrorParser.parse(e);
      if (!mounted) return;
      setState(() => _errorMessage = parsed.message);
    } finally {
      if (!mounted) return;
      setState(() => _isSendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim().toLowerCase();
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() => _errorMessage = 'Kod 6 haneli olmalıdır.');
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.verifyResetCode(
        VerifyResetCodeRequest(
          email: email,
          code: code,
          clientTs: _nowTs() - 1200,
        ),
      );

      if (!mounted) return;
      setState(() {
        _resetToken = response.resetToken;
        _codeVerified = response.resetToken.trim().isNotEmpty;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod doğrulandı. Yeni şifrenizi belirleyin.')));
    } catch (e) {
      final parsed = DioErrorParser.parse(e);
      if (!mounted) return;
      setState(() => _errorMessage = parsed.message);
    } finally {
      if (!mounted) return;
      setState(() => _isVerifyingCode = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    final newPassword = _newPasswordController.text.trim();
    final newPasswordAgain = _newPasswordAgainController.text.trim();
    final resetToken = (_resetToken ?? '').trim();

    if (newPassword != newPasswordAgain) {
      setState(() => _errorMessage = 'Şifreler eşleşmiyor.');
      return;
    }

    setState(() {
      _isResettingPassword = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(
        ResetPasswordRequest(
          email: email,
          resetToken: resetToken,
          newPassword: newPassword,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şifreniz başarıyla güncellendi.')));
      Navigator.pop(context);
    } catch (e) {
      final parsed = DioErrorParser.parse(e);
      if (!mounted) return;
      setState(() => _errorMessage = parsed.message);
    } finally {
      if (!mounted) return;
      setState(() => _isResettingPassword = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _newPasswordAgainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSendingCode || _isVerifyingCode || _isResettingPassword;
    final bgColor = isDarkMode ? darkBg : lightBg;
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (isDarkMode)
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: firAmber.withOpacity(0.05)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.lock_reset_rounded, color: firAmber, size: 60),
                            const SizedBox(height: 20),
                            Text(
                              'Şifre Sıfırlama',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Güvenliğiniz için 3 aşamalı doğrulama sürecini tamamlayın.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: mutedGray, fontSize: 13),
                            ),
                            const SizedBox(height: 30),

                            // ANA FORM KARTI
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.05), blurRadius: 40, offset: const Offset(0, 15))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 1. ADIM: E-POSTA
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'E-POSTA ADRESİ',
                                    icon: Icons.alternate_email,
                                    isDark: isDarkMode,
                                    enabled: !isBusy && !_codeVerified,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPrimaryButton(
                                    onPressed: (isBusy || _codeVerified) ? null : _sendCode,
                                    text: _codeSent ? 'Kodu Tekrar Gönder' : 'Doğrulama Kodu Gönder',
                                    isLoading: _isSendingCode,
                                    isSmall: true,
                                  ),

                                  const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white10)),

                                  // 2. ADIM: KOD
                                  _buildTextField(
                                    controller: _codeController,
                                    label: '6 HANELİ KOD',
                                    icon: Icons.pin_outlined,
                                    isDark: isDarkMode,
                                    enabled: !isBusy && _codeSent && !_codeVerified,
                                    maxLength: 6,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSecondaryButton(
                                    onPressed: (isBusy || _codeVerified || !_codeSent) ? null : _verifyCode,
                                    text: 'Kodu Doğrula',
                                    isLoading: _isVerifyingCode,
                                  ),

                                  const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white10)),

                                  // 3. ADIM: YENİ ŞİFRE
                                  _buildTextField(
                                    controller: _newPasswordController,
                                    label: 'YENİ ŞİFRE',
                                    icon: Icons.vpn_key_outlined,
                                    isDark: isDarkMode,
                                    enabled: !isBusy && _codeVerified,
                                    isPassword: true,
                                    obscureText: _obscurePassword,
                                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _newPasswordAgainController,
                                    label: 'YENİ ŞİFRE TEKRAR',
                                    icon: Icons.check_circle_outline,
                                    isDark: isDarkMode,
                                    enabled: !isBusy && _codeVerified,
                                    isPassword: true,
                                    obscureText: _obscurePasswordAgain,
                                    onToggleVisibility: () => setState(() => _obscurePasswordAgain = !_obscurePasswordAgain),
                                  ),

                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],

                                  const SizedBox(height: 24),
                                  _buildPrimaryButton(
                                    onPressed: (isBusy || !_codeVerified) ? null : _resetPassword,
                                    text: 'Şifreyi Güncelle',
                                    isLoading: _isResettingPassword,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç ve Geri Dön', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text('© FIRSAT', style: TextStyle(color: mutedGray, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET MODÜLLERİ ---
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

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(4),
        width: 60,
        decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(30)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: firAmber),
            child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 16, color: Colors.black),
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
    bool enabled = true,
    bool isPassword = false,
    bool obscureText = false,
    int? maxLength,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: enabled ? firAmber : mutedGray.withOpacity(0.5), letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          maxLength: maxLength,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: Icon(icon, color: enabled ? mutedGray : mutedGray.withOpacity(0.2), size: 18),
            suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: mutedGray, size: 18), onPressed: onToggleVisibility) : null,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.02))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: firAmber, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required VoidCallback? onPressed, required String text, bool isLoading = false, bool isSmall = false}) {
    return Container(
      height: isSmall ? 45 : 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: onPressed == null ? null : const LinearGradient(colors: [firAmber, Color(0xFFD97706)]),
        color: onPressed == null ? Colors.white10 : null,
        boxShadow: onPressed == null ? [] : [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : Text(text, style: TextStyle(color: onPressed == null ? mutedGray : Colors.black, fontWeight: FontWeight.w900, fontSize: isSmall ? 14 : 16)),
      ),
    );
  }

  Widget _buildSecondaryButton({required VoidCallback? onPressed, required String text, bool isLoading = false}) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: onPressed == null ? Colors.white10 : firAmber.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: firAmber,
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: firAmber, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}