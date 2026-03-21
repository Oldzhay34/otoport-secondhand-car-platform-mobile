import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/auth/models/verify_email_request.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthService _authService = AuthService();
  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isDarkMode = true;

  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color mutedGray = Color(0xFF9AA3B2);

  Future<void> verifyEmail() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      setState(() => errorMessage = 'Doğrulama kodu zorunludur.');
      return;
    }

    if (code.length != 6) {
      setState(() => errorMessage = 'Kod 6 haneli olmalıdır.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _authService.verifyEmail(
        VerifyEmailRequest(
          email: widget.email,
          code: code,
        ),
      );

      if (!mounted) return;

      if (result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta doğrulandı. Giriş yapabilirsiniz.')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      } else {
        setState(() {
          errorMessage = result['message']?.toString() ?? 'Doğrulama başarısız.';
        });
      }
    } catch (e) {
      setState(() => errorMessage = 'Doğrulama başarısız: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    codeController.dispose();
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
          if (isDarkMode)
            Positioned(
              bottom: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: firAmber.withOpacity(0.06),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                            const Icon(
                              Icons.mark_email_read_outlined,
                              color: firAmber,
                              size: 64,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'E-posta Doğrulama',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: mutedGray,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: "Lütfen "),
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      color: firAmber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                    " adresine gönderilen 6 haneli kodu giriniz.",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDarkMode ? 0.4 : 0.05,
                                    ),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildCodeField(isDark: isDarkMode),
                                  if (errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  _buildPrimaryButton(
                                    onPressed: isLoading ? null : verifyEmail,
                                    text: 'Doğrula ve Devam Et',
                                    isLoading: isLoading,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'E-posta adresini değiştir',
                                style: TextStyle(
                                  color: mutedGray,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(
                    '© FIRSAT',
                    style: TextStyle(
                      color: mutedGray,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          children: [
            TextSpan(
              text: "FIR",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
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
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment:
          isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: firAmber,
            ),
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

  Widget _buildCodeField({required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DOĞRULAMA KODU',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: firAmber,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 15,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: "000000",
            hintStyle: TextStyle(color: mutedGray.withOpacity(0.3)),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: firAmber, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [firAmber, Color(0xFFD97706)],
        ),
        boxShadow: [
          BoxShadow(
            color: firAmber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 3,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}