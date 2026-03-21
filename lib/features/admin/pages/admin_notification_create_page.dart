import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_notification_create_request.dart';
import 'package:otoport_mobile/features/admin/models/admin_store_option_dto.dart';
import 'package:otoport_mobile/features/admin/service/admin_notification_service.dart';
import 'package:otoport_mobile/features/admin/widgets/admin_bottom_nav_bar.dart';

class AdminNotificationCreatePage extends StatefulWidget {
  const AdminNotificationCreatePage({super.key});

  @override
  State<AdminNotificationCreatePage> createState() => _AdminNotificationCreatePageState();
}

class _AdminNotificationCreatePageState extends State<AdminNotificationCreatePage> {
  final AdminNotificationService _service = AdminNotificationService();

  // --- CONTROLLERLAR ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  bool sendToAllStores = true;
  String selectedType = 'SYSTEM';
  int? selectedStoreId;
  List<AdminStoreOptionDto> stores = [];

  final List<String> notificationTypes = const [
    'NEW_MESSAGE', 'SAVED_SEARCH_MATCH', 'LISTING_APPROVED',
    'LISTING_REJECTED', 'STORE_VERIFIED', 'SYSTEM',
  ];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _loadStores() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = await _service.getStores();
      if (!mounted) return;
      setState(() => stores = data);
    } catch (e) {
      setState(() => errorMessage = 'Mağaza listesi alınamadı.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir başlık girin.')));
      return;
    }
    if (!sendToAllStores && selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir hedef mağaza seçin.')));
      return;
    }

    setState(() => isSending = true);
    try {
      await _service.create(AdminNotificationCreateRequest(
        storeId: sendToAllStores ? null : selectedStoreId,
        type: selectedType, title: title,
        message: _messageController.text.isEmpty ? null : _messageController.text.trim(),
        payloadJson: _payloadController.text.isEmpty ? null : _payloadController.text.trim(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bildirim başarıyla gönderildi.')));
      _titleController.clear(); _messageController.clear(); _payloadController.clear();
      setState(() { sendToAllStores = true; selectedType = 'SYSTEM'; selectedStoreId = null; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bildirim gönderilemedi.')));
    } finally {
      if (mounted) setState(() => isSending = false);
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
          IconButton(icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: firAmber), onPressed: () => setState(() => isDarkMode = !isDarkMode)),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _loadStores,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildIntroInfo(),
            const SizedBox(height: 24),

            _sectionHeader('1. HEDEF KİTLE SEÇİMİ', Icons.groups_rounded),
            _premiumCard(cardColor, _buildTargetSelection(textColor, cardColor)),

            const SizedBox(height: 24),
            _sectionHeader('2. BİLDİRİM İÇERİĞİ', Icons.chat_bubble_rounded),
            _premiumCard(cardColor, _buildNotificationForm(textColor, cardColor)),

            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildIntroInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: firAmber.withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: firAmber, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text('Bu panelden mağaza sahiplerine sistem bildirimleri veya özel duyurular gönderebilirsiniz.', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildTargetSelection(Color textColor, Color dropdownBg) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Genel Yayın (Broadcast)', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14)),
          subtitle: Text(sendToAllStores ? 'Bildirim tüm mağazalara gidecek.' : 'Sadece seçilen mağazaya gidecek.', style: const TextStyle(color: mutedGray, fontSize: 12)),
          activeColor: firAmber,
          value: sendToAllStores,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() { sendToAllStores = v; if(v) selectedStoreId = null; }),
        ),
        if (!sendToAllStores) ...[
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
          _premiumDropdown<int>(
            selectedStoreId,
            // 1. Sadece null olmayan ID'leri alıp listeliyoruz
            stores.map((s) => s.id).whereType<int>().toList(),
                (v) => setState(() => selectedStoreId = v),
                (v) {
              // 2. ID'ye karşılık gelen mağazayı 'stores' listesi içinde arıyoruz
              // foundStore null dönerse (bulunamazsa) 'Mağaza Seçilmedi' yazacak
              final foundStore = stores.cast<AdminStoreOptionDto?>().firstWhere(
                    (s) => s?.id == v,
                orElse: () => null,
              );
              return foundStore?.displayLabel ?? 'Mağaza Seçilmedi';
            },
            textColor,
            dropdownBg,
            'Hedef Mağazayı Seçin',
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationForm(Color textColor, Color dropdownBg) {
    return Column(
      children: [
        _premiumDropdown<String>(selectedType, notificationTypes, (v) => setState(() => selectedType = v!), (v) => v.replaceAll('_', ' '), textColor, dropdownBg, 'Bildirim Tipi'),
        const SizedBox(height: 16),
        _premiumTextField(_titleController, 'Bildirim Başlığı', 'Kısa ve öz bir başlık...', textColor),
        const SizedBox(height: 16),
        _premiumTextField(_messageController, 'Detaylı Mesaj', 'Duyuru metnini buraya yazın...', textColor, maxLines: 4),
        const SizedBox(height: 16),
        _premiumTextField(_payloadController, 'Teknik Veri (Payload JSON)', '{"action": "open_tab"}', textColor, maxLines: 4, isCode: true),
      ],
    );
  }

  // --- HELPERS ---

  Widget _sectionHeader(String t, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Icon(i, color: firAmber, size: 18), const SizedBox(width: 8), Text(t, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))]));

  Widget _premiumCard(Color c, Widget ch) => Container(padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)), child: ch);

  Widget _premiumTextField(TextEditingController ctrl, String label, String hint, Color txtColor, {int maxLines = 1, bool isCode = false}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      style: TextStyle(color: txtColor, fontSize: 14, fontFamily: isCode ? 'monospace' : null),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 12),
        hintText: hint, hintStyle: TextStyle(color: mutedGray.withOpacity(0.5)),
        filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _premiumDropdown<T>(T? val, List<T> items, Function(T?) onChg, String Function(T) labelB, Color txtColor, Color bg, String label) {
    return DropdownButtonFormField<T>(
      value: val, dropdownColor: bg,
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
      child: ElevatedButton.icon(
        onPressed: isSending ? null : _submit,
        icon: isSending
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
        label: Text(isSending ? 'GÖNDERİLİYOR...' : 'BİLDİRİMİ YAYINLA', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }

  @override void dispose() { _titleController.dispose(); _messageController.dispose(); _payloadController.dispose(); super.dispose(); }
}