import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';
import 'package:otoport_mobile/features/store/model/store_home_dto.dart';
import 'package:otoport_mobile/features/store/model/store_listing_row_dto.dart';
import 'package:otoport_mobile/features/store/pages/store_inbox_page.dart';
import 'package:otoport_mobile/features/store/pages/store_listing_detail_page.dart';
import 'package:otoport_mobile/features/store/pages/store_listing_edit_page.dart';
import 'package:otoport_mobile/features/store/pages/store_notifications_page.dart';
import 'package:otoport_mobile/features/store/pages/store_old_listings_page.dart';
import 'package:otoport_mobile/features/store/pages/store_profile_page.dart';
import 'package:otoport_mobile/features/store/pages/store_erp_page.dart';
import 'package:otoport_mobile/features/store/pages/store_subscription_page.dart';
import 'package:otoport_mobile/features/store/pages/store_listing_create_page.dart';
import '../service/store_home_service.dart';
import '../service/store_inquiry_service.dart';
import '../service/store_listing_management_service.dart';
import '../service/store_notification_service.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  // --- SERVISLER ---
  final StoreHomeService _storeHomeService = StoreHomeService();
  final StoreNotificationService _notificationService = StoreNotificationService();
  final StoreInquiryService _inquiryService = StoreInquiryService();
  final StoreListingManagementService _listingManagementService = StoreListingManagementService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _searchController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;
  StoreHomeDto? home;
  int unreadNotificationCount = 0;
  int unreadInquiryCount = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await Future.wait([
      _loadHome(),
      _loadUnreadCount(),
      _loadInquiryUnreadCount(),
    ]);
  }

  // --- MANTIK FONKSIYONLARI (EKSİKSİZ KORUNDU) ---

  Future<void> _loadHome({String? q}) async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _storeHomeService.getMyHome(q: q);
      if (!mounted) return;
      setState(() { home = result; });
    } catch (e) {
      setState(() => errorMessage = 'Mağaza verileri yüklenemedi.');
    } finally {
      if (mounted) setState(() { isLoading = false; isSearching = false; });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      setState(() => unreadNotificationCount = count);
    } catch (_) {}
  }

  Future<void> _loadInquiryUnreadCount() async {
    try {
      final count = await _inquiryService.getUnreadCount();
      setState(() => unreadInquiryCount = count);
    } catch (_) {}
  }

  Future<void> _deleteListing(StoreListingRowDto item) async {
    final id = item.id; if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? darkCard : Colors.white,
        title: Text('İlanı Sil', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        content: const Text('Bu ilanı kalıcı olarak silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ', style: TextStyle(color: mutedGray))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('SİL', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final ok = await _listingManagementService.delete(id);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan başarıyla silindi.')));
        _initializePage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silme işlemi başarısız.')));
    }
  }

  Future<void> _logout() async {
    try { await _authService.logout(); } catch (_) {}
    await _tokenStorage.clearAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
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
        actions: [
          _buildThemeToggle(),
          const SizedBox(width: 8),
          _appBarBadgeIcon(Icons.mail_outline_rounded, unreadInquiryCount, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreInboxPage())).then((_) => _loadInquiryUnreadCount())),
          _appBarBadgeIcon(Icons.notifications_none_rounded, unreadNotificationCount, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreNotificationsPage())).then((_) => _loadUnreadCount())),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22), onPressed: _logout),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _initializePage,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (home != null) ...[
              _buildHeaderCard(home!, cardColor, textColor),
              const SizedBox(height: 20),
              _buildQuickActions(home!, cardColor, textColor),
              const SizedBox(height: 20),
              _buildPremiumNotice(home!),
              const SizedBox(height: 20),
              _buildSearchCard(cardColor, textColor),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('İlanlarım'.toUpperCase(), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text('${home!.listings.length} İlan', style: const TextStyle(color: firAmber, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              if (home!.listings.isEmpty) _buildEmptyState() else ...home!.listings.map((item) => _buildListingCard(item, cardColor, textColor)),
              const SizedBox(height: 50),
            ]
          ],
        ),
      ),
    );
  }

  // --- UI ALT BİLEŞENLERİ ---

  Widget _appBarBadgeIcon(IconData icon, int count, VoidCallback onTap) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon, color: mutedGray), onPressed: onTap),
        if (count > 0)
          Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: firAmber, shape: BoxShape.circle), child: Text('$count', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)))),
      ],
    );
  }

  Widget _buildHeaderCard(StoreHomeDto data, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: firAmber, child: Text(data.storeName.isNotEmpty ? data.storeName[0].toUpperCase() : 'S', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.storeName, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 12, color: firAmber),
                    const SizedBox(width: 4),
                    Text(data.locationText, style: const TextStyle(color: mutedGray, fontSize: 12)),
                    if (data.verified) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified_rounded, size: 14, color: Colors.blueAccent),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _buildCircleAction(Icons.settings_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreProfilePage()))),
        ],
      ),
    );
  }

  Widget _buildQuickActions(StoreHomeDto data, Color cardColor, Color textColor) {
    return Row(
      children: [
        _quickActionBtn(Icons.add_box_rounded, 'İlan Ver', data.canCreateListing ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreListingCreatePage())).then((v) => v == true ? _initializePage() : null) : () => _goSubscriptions(), cardColor, textColor, isPrimary: true),
        const SizedBox(width: 12),
        _quickActionBtn(Icons.analytics_rounded, 'ERP / Analiz', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreErpPage())), cardColor, textColor, isPrimary: false),
        const SizedBox(width: 12),
        _quickActionBtn(Icons.history_rounded, 'Eski İlanlar', () => _goOldListings(), cardColor, textColor, isPrimary: false),
      ],
    );
  }

  Widget _quickActionBtn(IconData icon, String label, VoidCallback onTap, Color cardColor, Color textColor, {required bool isPrimary}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? firAmber : cardColor,
            borderRadius: BorderRadius.circular(20),
            border: isPrimary ? null : Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
            boxShadow: isPrimary ? [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isPrimary ? Colors.black : firAmber, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isPrimary ? Colors.black : textColor, fontWeight: FontWeight.w900, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumNotice(StoreHomeDto data) {
    if (!data.subscriptionExpired && data.canCreateListing) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: firAmber.withOpacity(0.4))),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: firAmber, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.subscriptionExpired ? 'Abonelik Süreniz Doldu' : 'İlan Limitine Ulaştınız', style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Yeni ilanlar yayınlamak için paketinizi güncelleyin.', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          TextButton(onPressed: _goSubscriptions, child: const Text('PAKETLER', style: TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildSearchCard(Color cardColor, Color textColor) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: mutedGray, size: 20),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _searchController, onSubmitted: (_) => _search(), style: TextStyle(color: textColor, fontSize: 14), decoration: const InputDecoration(hintText: 'İlanlarımda ara...', border: InputBorder.none, hintStyle: TextStyle(color: mutedGray)))),
          if (isSearching) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: firAmber)) else IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: firAmber), onPressed: _search),
        ],
      ),
    );
  }

  Widget _buildListingCard(StoreListingRowDto item, Color cardColor, Color textColor) {
    final imageUrl = _normalizeImageUrl(item.coverImageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: GestureDetector(
              onTap: () => _openImagePreview(imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 60,
                    color: Colors.black12,
                    child: const Icon(Icons.image_not_supported, color: mutedGray),
                  ),
                ),
              ),
            ),
            title: Text(
              item.title.isEmpty ? 'İsimsiz İlan' : item.title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: firAmber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: firAmber.withOpacity(0.3)),
                    ),
                    child: Text(
                      _formatMoney(item.price, item.currency),
                      style: const TextStyle(
                        color: firAmber,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statusBadge(item.status),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDateTime(item.createdAt),
                          style: const TextStyle(color: mutedGray, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: mutedGray,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoreListingDetailPage(listingId: item.id!),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _listActionBtn(
                    'GÜNCELLE',
                    Icons.edit_note_rounded,
                    Colors.blueAccent,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoreListingEditPage(listingId: item.id!),
                      ),
                    ).then((v) => v == true ? _initializePage() : null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _listActionBtn(
                    'SİL',
                    Icons.delete_outline_rounded,
                    Colors.redAccent,
                        () => _deleteListing(item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _listActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withOpacity(0.3))),
      child: Text(status.isEmpty ? 'AKTİF' : status, style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), shape: BoxShape.circle), child: Icon(icon, color: firAmber, size: 20)));
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(children: [Icon(Icons.directions_car_outlined, size: 48, color: mutedGray.withOpacity(0.3)), const SizedBox(height: 12), const Text('Henüz bir ilanınız bulunmuyor.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))]),
    );
  }

  // --- FORMATTERS ---
  String _normalizeImageUrl(String? path) {
    return ImageService.withFallback(path);
  }
  String _formatMoney(double? v, String cur) => v == null ? '—' : '${v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} $cur';
  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year}';
  }

  Future<void> _search() async { setState(() => isSearching = true); await _loadHome(q: _searchController.text.trim()); }
  Future<void> _goOldListings() async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreOldListingsPage())); _initializePage(); }
  Future<void> _goInbox() async => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreInboxPage()));
  Future<void> _goNotifications() async => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreNotificationsPage()));
  Future<void> _goSubscriptions() async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreSubscriptionPage())); _initializePage(); }

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


  @override void dispose() { _searchController.dispose(); super.dispose(); }
}