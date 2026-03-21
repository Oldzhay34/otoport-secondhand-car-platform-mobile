import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/pages/register_page.dart';

class FavoritesGuestGatePage extends StatefulWidget {
  const FavoritesGuestGatePage({super.key});

  @override
  State<FavoritesGuestGatePage> createState() => _FavoritesGuestGatePageState();
}

class _FavoritesGuestGatePageState extends State<FavoritesGuestGatePage> {
  bool isDarkMode = true; // Varsayılan premium koyu mod

  // Renk Paleti
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);

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
          _buildThemeToggle(),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // Arka plan dekoratif parlama (Glow)
          if (isDarkMode)
            Positioned(
              top: 40,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: firAmber.withOpacity(0.08),
                ),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container()),
              ),
            ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // İkon Alanı
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: firAmber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded, size: 48, color: firAmber),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Favoriler Sizi Bekliyor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Beğendiğiniz araçları listelemek ve fırsatları kaçırmamak için oturum açmanız gerekiyor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mutedGray,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Kayıt Ol Butonu (Primary Gradient)
                      _buildPrimaryBtn(
                        text: 'Hemen Kayıt Ol',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                        },
                      ),
                      const SizedBox(height: 12),

                      // Giriş Yap Butonu (Secondary Outlined)
                      _buildSecondaryBtn(
                        text: 'Giriş Yap',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Vazgeç ve Göz Atmaya Devam Et',
                          style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Web'deki premium logo tasarımı
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

  // Tema Değiştirme Butonu
  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: firAmber),
            child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryBtn({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]),
        boxShadow: [
          BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSecondaryBtn({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: firAmber, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: firAmber,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}