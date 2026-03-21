import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/auth/models/register_request.dart';
import 'package:otoport_mobile/features/auth/models/register_response.dart';
import 'package:otoport_mobile/features/auth/pages/verify_email_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool marketingConsent = false;
  bool termsAccepted = false;
  bool privacyPolicyAccepted = false;
  bool explicitConsentAccepted = false;

  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;
  bool isDarkMode = true;

  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color mutedGray = Color(0xFF9AA3B2);

  static const String termsText = '''
Fırsat platformu, kullanıcıların araç ilanlarını görüntülemesine, mağazalarla iletişim kurmasına ve araç keşif süreçlerini yönetmesine olanak sağlar.

Platformu kullanan her kullanıcı:
- Türkiye Cumhuriyeti mevzuatına uygun davranacağını,
- Küfür, hakaret, tehdit, taciz, spam ve yanıltıcı içerik paylaşmayacağını,
- Başkalarına ait hesapları izinsiz kullanmayacağını,
- Sistemin güvenliğini zedeleyecek girişimlerde bulunmayacağını,
- Sahte ilan, aldatıcı bilgi veya dolandırıcılık amacı taşıyan işlem yapmayacağını
kabul eder.

Fırsat, uygunsuz içerikleri kaldırma, hesapları askıya alma veya kapatma hakkını saklı tutar.

Platform 18 yaş altı bireyler için uygun değildir. Kullanıcı, kayıt oluşturarak 18 yaşından büyük olduğunu beyan eder.

Fırsat, hizmeti teknik nedenlerle güncelleme, değiştirme, durdurma veya sınırlandırma hakkını saklı tutar.
''';

  static const String privacyText = '''
Fırsat, kullanıcıların kişisel verilerini 6698 sayılı Kişisel Verilerin Korunması Kanunu (“KVKK”) kapsamında işlemektedir.

İşlenebilecek veriler:
- Ad, soyad
- E-posta adresi
- Telefon numarası
- IP adresi ve oturum kayıtları
- Platform kullanım bilgileri
- Mesajlaşma ve güvenlik kayıtları

Veriler şu amaçlarla işlenebilir:
- Hesap oluşturma ve kullanıcı doğrulama
- Güvenliğin sağlanması
- Yetkisiz erişimlerin önlenmesi
- Platformun geliştirilmesi
- Yasal yükümlülüklerin yerine getirilmesi

Kişisel veriler, ilgili mevzuatın öngördüğü süre boyunca veya işleme amacı devam ettiği sürece saklanır.

Platform 18 yaş altı bireylere yönelik değildir ve çocuklara ait kişisel veriler bilerek işlenmez.
''';

  static const String consentText = '''
Açık rızanız kapsamında, Fırsat tarafından kişisel verilerinizin aşağıdaki amaçlarla işlenmesine onay vermiş olursunuz:

- Kullanıcı deneyiminin geliştirilmesi
- Tercihlerinize göre içerik sunulması
- Hizmet kalitesinin artırılması
- Güvenlik, denetim ve analiz süreçlerinin yürütülmesi

Ayrıca, gerekli olduğu ölçüde verileriniz; barındırma, e-posta gönderimi, güvenlik ve teknik altyapı hizmeti sunan iş ortaklarıyla, KVKK’ya uygun şekilde paylaşılabilir.

Açık rıza vermemeniz halinde kayıt işlemi tamamlanmayacaktır.
''';

  Future<void> register() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() => errorMessage = 'Lütfen tüm zorunlu alanları doldurun.');
      return;
    }

    if (!termsAccepted || !privacyPolicyAccepted || !explicitConsentAccepted) {
      setState(() {
        errorMessage =
        'Kayıt olmak için Kullanım Koşulları, Gizlilik Politikası ve Açık Rıza Metni onaylanmalıdır.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone.isEmpty ? null : phone,
        hp: '',
        marketingConsent: marketingConsent,
        termsAccepted: termsAccepted,
        privacyPolicyAccepted: privacyPolicyAccepted,
        explicitConsentAccepted: explicitConsentAccepted,
      );

      final RegisterResponse result = await _authService.register(request);
      if (!mounted) return;

      if (result.verificationRequired) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailPage(email: result.email ?? email),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Kayıt işlemi başlatılamadı.';
        });
      }
    } catch (e) {
      setState(() => errorMessage = 'Bağlantı hatası oluştu: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showLegalDialog(String title, String content) {
    final bg = isDarkMode ? darkCard : Colors.white;
    final txt = isDarkMode ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: txt,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: txt),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: txt.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
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
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: firAmber.withOpacity(0.07),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Yeni Hesap Oluştur',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'FIRSAT dünyasına katılmak için bilgilerinizi girin',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: mutedGray,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
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
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: firstNameController,
                                          label: 'Ad',
                                          icon: Icons.person_outline,
                                          isDark: isDarkMode,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: lastNameController,
                                          label: 'Soyad',
                                          icon: Icons.person_outline,
                                          isDark: isDarkMode,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: emailController,
                                    label: 'E-posta',
                                    icon: Icons.alternate_email,
                                    isDark: isDarkMode,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: passwordController,
                                    label: 'Şifre',
                                    icon: Icons.lock_outline,
                                    isDark: isDarkMode,
                                    isPassword: true,
                                    obscureText: obscurePassword,
                                    onToggleVisibility: () => setState(
                                          () => obscurePassword = !obscurePassword,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: phoneController,
                                    label: 'Telefon (Opsiyonel)',
                                    icon: Icons.phone_android,
                                    isDark: isDarkMode,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 16),
                                  Theme(
                                    data: ThemeData(
                                      unselectedWidgetColor: mutedGray,
                                    ),
                                    child: CheckboxListTile(
                                      value: marketingConsent,
                                      onChanged: (val) => setState(
                                            () => marketingConsent = val ?? false,
                                      ),
                                      title: const Text(
                                        'Kampanya ve bilgilendirme onayı veriyorum',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: mutedGray,
                                        ),
                                      ),
                                      activeColor: firAmber,
                                      checkColor: Colors.black,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                      ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  _buildLegalCheckbox(
                                    value: termsAccepted,
                                    onChanged: (v) => setState(
                                          () => termsAccepted = v ?? false,
                                    ),
                                    label: 'Kullanım Koşulları',
                                    onOpen: () => _showLegalDialog(
                                      'Kullanım Koşulları',
                                      termsText,
                                    ),
                                  ),
                                  _buildLegalCheckbox(
                                    value: privacyPolicyAccepted,
                                    onChanged: (v) => setState(
                                          () => privacyPolicyAccepted = v ?? false,
                                    ),
                                    label: 'Gizlilik Politikası',
                                    onOpen: () => _showLegalDialog(
                                      'Gizlilik Politikası',
                                      privacyText,
                                    ),
                                  ),
                                  _buildLegalCheckbox(
                                    value: explicitConsentAccepted,
                                    onChanged: (v) => setState(
                                          () => explicitConsentAccepted = v ?? false,
                                    ),
                                    label: 'Açık Rıza Metni',
                                    onOpen: () => _showLegalDialog(
                                      'Açık Rıza Metni',
                                      consentText,
                                    ),
                                  ),
                                  if (errorMessage != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  _buildPrimaryButton(
                                    onPressed: isLoading ? null : register,
                                    text: 'Kayıt Ol',
                                    isLoading: isLoading,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: "Zaten hesabın var mı? ",
                                  style: const TextStyle(color: mutedGray),
                                  children: const [
                                    TextSpan(
                                      text: "Giriş Yap",
                                      style: TextStyle(
                                        color: firAmber,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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

  Widget _buildLegalCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required VoidCallback onOpen,
  }) {
    final txt = isDarkMode ? Colors.white : Colors.black87;

    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: firAmber,
      checkColor: Colors.black,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: txt.withOpacity(0.9),
            fontSize: 12,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(
                color: firAmber,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = onOpen,
            ),
            const TextSpan(
              text: ' metnini okudum ve kabul ediyorum.',
            ),
          ],
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: firAmber,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mutedGray, size: 18),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: mutedGray,
                size: 18,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
  }) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [firAmber, Color(0xFFD97706)],
        ),
        boxShadow: [
          BoxShadow(
            color: firAmber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
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