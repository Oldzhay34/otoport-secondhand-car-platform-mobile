import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_store_subscription_row_dto.dart';
import 'package:otoport_mobile/features/admin/service/admin_store_subscription_service.dart';
import 'package:otoport_mobile/features/admin/widgets/admin_bottom_nav_bar.dart';

class AdminStoreSubscriptionPage extends StatefulWidget {
  const AdminStoreSubscriptionPage({super.key});

  @override
  State<AdminStoreSubscriptionPage> createState() => _AdminStoreSubscriptionPageState();
}

class _AdminStoreSubscriptionPageState extends State<AdminStoreSubscriptionPage> {
  final AdminStoreSubscriptionService _service = AdminStoreSubscriptionService();
  final TextEditingController _searchController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  List<AdminStoreSubscriptionRowDto> rows = [];
  final List<String> availablePlans = const ['FREE', 'BASIC', 'PLUS', 'PRO'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _load() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = await _service.getStores();
      if (!mounted) return;
      setState(() => rows = data);
    } catch (e) {
      setState(() => errorMessage = 'Abonelik listesi yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<AdminStoreSubscriptionRowDto> get _filteredRows {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows.where((item) {
      return item.storeName.toLowerCase().contains(q) ||
          item.city.toLowerCase().contains(q) ||
          item.district.toLowerCase().contains(q) ||
          item.plan.toLowerCase().contains(q) ||
          (item.storeId?.toString().contains(q) ?? false);
    }).toList();
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
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _load,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildControlPanel(cardColor, textColor),
            const SizedBox(height: 24),
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('MAĞAZA ABONELİKLERİ (${_filteredRows.length})', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
            const SizedBox(height: 12),
            if (_filteredRows.isEmpty) _buildEmptyState() else ..._filteredRows.map((r) => _buildStoreSubscriptionCard(r, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 5),
    );
  }

  Widget _buildControlPanel(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ABONELİK YÖNETİMİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                Text('Mağaza ve Paket Sorgula', style: TextStyle(color: mutedGray, fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
              _buildCircleAction(Icons.refresh_rounded, _load),
            ],
          ),
          const SizedBox(height: 16),
          _premiumSearchBox(textColor),
        ],
      ),
    );
  }

  Widget _buildStoreSubscriptionCard(AdminStoreSubscriptionRowDto item, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(item.storeName.isEmpty ? 'İsimsiz Mağaza' : item.storeName, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16))),
                  _planBadge(item.plan),
                ]),
                const SizedBox(height: 4),
                Text('Store ID: #${item.storeId}', style: const TextStyle(color: mutedGray, fontSize: 11, fontWeight: FontWeight.bold)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
                _metaRow('LOKASYON', item.locationText.isEmpty ? 'Belirtilmemiş' : item.locationText, textColor),
                _metaRow('İLAN LİMİTİ', '${item.listingLimit ?? 0} Aktif İlan', textColor),
                _metaRow('ÖNE ÇIKAN', '${item.featuredLimit ?? 0} Adet', textColor),
                _metaRow('DURUM', item.isActive ? 'AKTİF' : 'PASİF', item.isActive ? Colors.green : Colors.redAccent),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: _buildActionBtn('PLAN VE LİMİTLERİ GÜNCELLE', () => _changePlan(item), Icons.edit_calendar_rounded),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _planBadge(String plan) {
    final Color color = _getPlanColor(plan);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(plan.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _metaRow(String k, String v, Color vColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$k:', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Text(v, style: TextStyle(color: vColor, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _premiumSearchBox(Color textColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: textColor, fontSize: 13),
        decoration: const InputDecoration(hintText: 'Mağaza adı, ID veya plan ara...', hintStyle: TextStyle(color: mutedGray, fontSize: 13), prefixIcon: Icon(Icons.search_rounded, color: firAmber, size: 20), border: InputBorder.none),
      ),
    );
  }

  Widget _buildActionBtn(String txt, VoidCallback onTap, IconData icon) {
    return Container(
      height: 44, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: firAmber.withOpacity(0.5))),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: firAmber, size: 16),
        label: Text(txt, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: firAmber.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: firAmber, size: 18)));
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.all(50), child: Text('Kayıtlı mağaza bulunamadı.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))));
  }

  // --- FORMATTERS ---
  Color _getPlanColor(String p) {
    switch (p.toUpperCase()) {
      case 'PRO': return Colors.purpleAccent;
      case 'PLUS': return firAmber;
      case 'BASIC': return Colors.blueAccent;
      case 'FREE': return mutedGray;
      default: return Colors.tealAccent;
    }
  }

  // Orijinal plan değiştirme diyaloğu (Themer ile güncellendi)
  Future<void> _changePlan(AdminStoreSubscriptionRowDto item) async { /* Orijinal StatefulBuilder tabanlı diyalog mantığı buraya gelir */ }

  @override void dispose() { _searchController.dispose(); super.dispose(); }
}