import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/admin/models/admin_daily_stats_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_hourly_traffic_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_realtime_traffic_dto.dart';
import 'package:otoport_mobile/features/admin/pages/admin_audit_log_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_client_status_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_event_log_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_message_report_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_notification_create_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_store_account_create_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_store_subscription_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_wal_page.dart';
import 'package:otoport_mobile/features/admin/service/admin_dashboard_service.dart';
import 'package:otoport_mobile/features/admin/widgets/admin_bottom_nav_bar.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminDashboardService _service = AdminDashboardService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  AdminDailyVisitStatsDto? daily;
  AdminHourlyTrafficDto? hourly;
  AdminRealtimeTrafficDto? realtime;
  int realtimeWindow = 5;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // --- LOGIC (SADELEŞTİRİLDİ) ---
  Future<void> _initializePage() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final today = _todayTr();
      final results = await Future.wait([
        _service.getDaily(date: today),
        _service.getHourly(date: today),
        _service.getRealtime(windowMinutes: realtimeWindow),
      ]);
      if (!mounted) return;
      setState(() {
        daily = results[0] as AdminDailyVisitStatsDto;
        hourly = results[1] as AdminHourlyTrafficDto;
        realtime = results[2] as AdminRealtimeTrafficDto;
      });
    } catch (e) {
      setState(() => errorMessage = 'Veriler şu an alınamıyor.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _refreshRealtime(int window) async {
    try {
      final data = await _service.getRealtime(windowMinutes: window);
      setState(() { realtime = data; realtimeWindow = window; });
    } catch (_) {}
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
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22), onPressed: _logout),
          const SizedBox(width: 12),
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
            _buildAdminBadge(),
            const SizedBox(height: 24),

            _sectionTitle('Bugünkü Performans', textColor),
            _buildDailyStatsGrid(cardColor, textColor),

            const SizedBox(height: 24),
            _buildRealtimeCard(cardColor, textColor),

            const SizedBox(height: 24),
            _buildHourlyTrafficCard(cardColor, textColor),

            const SizedBox(height: 24),
            _sectionTitle('Hızlı Yönetim Paneli', textColor),
            _buildQuickActionsGrid(cardColor, textColor),

            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: firAmber.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.admin_panel_settings_rounded, color: firAmber, size: 16),
          const SizedBox(width: 8),
          const Text('SİSTEM YÖNETİCİSİ PANELİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildDailyStatsGrid(Color cardColor, Color textColor) {
    if (daily == null) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('ZİYARET', daily!.total.toString(), Icons.remove_red_eye_outlined, cardColor, textColor),
        _statCard('MİSAFİR', daily!.guest.toString(), Icons.person_outline, cardColor, textColor),
        _statCard('ÜYE', daily!.client.toString(), Icons.people_outline, cardColor, textColor),
        _statCard('MAĞAZA', daily!.store.toString(), Icons.storefront_outlined, cardColor, textColor),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: firAmber, size: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ]),
        ],
      ),
    );
  }

  Widget _buildRealtimeCard(Color cardColor, Color textColor) {
    final data = realtime;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: firAmber.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: firAmber.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ANLIK TRAFİK', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
              Text('Son ${data?.windowMinutes ?? realtimeWindow} Dakika', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            _buildCircleAction(Icons.refresh_rounded, () => _refreshRealtime(realtimeWindow)),
          ]),
          const SizedBox(height: 24),
          Text('${data?.total ?? 0}', style: TextStyle(color: textColor, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const Text('AKTİF KULLANICI', style: TextStyle(color: mutedGray, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniTrafficInfo('MİSAFİR', data?.guest ?? 0),
              _miniTrafficInfo('ÜYE', data?.client ?? 0),
              _miniTrafficInfo('MAĞAZA', data?.store ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyTrafficCard(Color cardColor, Color textColor) {
    if (hourly == null) return const SizedBox.shrink();

    // Trafiği 0'dan büyük olan saatleri al
    final nonZero = hourly!.hours.where((e) => e.count > 0).toList();

    // Ekranda gösterilecek liste (Boşsa ilk 6 saati, doluysa trafiği olanları göster)
    final List<dynamic> items = nonZero.isEmpty
        ? hourly!.hours.take(6).toList()
        : nonZero.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SAATLİK TRAFİK YOĞUNLUĞU',
              style: TextStyle(color: mutedGray, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...items.map((it) {
            // --- HATA BURADAYDI, ŞİMDİ GÜVENLİ HALE GETİRDİK ---
            // Eğer liste boşsa max değeri 1 al (bölme hatası olmasın), değilse reduce ile bul.
            final maxCount = nonZero.isEmpty
                ? 1
                : nonZero.map((e) => e.count).reduce((a, b) => a > b ? a : b);

            // Değer 0 ise progress bar çökmemesi için clamp kullanıyoruz
            final double progressValue = it.count / (maxCount == 0 ? 1 : maxCount);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                SizedBox(width: 40, child: Text('${it.hour}:00',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold))),
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03),
                            color: firAmber,
                            minHeight: 8
                        )
                    )
                ),
                const SizedBox(width: 12),
                Text('${it.count}', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12)),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(Color cardColor, Color textColor) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _quickAction('PAKETLER', Icons.inventory_2_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStoreSubscriptionPage()))),
        _quickAction('ÜYELER', Icons.people_alt_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminClientStatusPage()))),
        _quickAction('MAĞAZA', Icons.add_business_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStoreAccountCreatePage()))),
        _quickAction('RAPORLAR', Icons.flag_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMessageReportsPage()))),
        _quickAction('BİLDİRİM', Icons.notifications_active_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationCreatePage()))),
        _quickAction('WAL LOG', Icons.rule_folder_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalPage()))),
      ],
    );
  }

  // --- HELPERS ---

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: firAmber, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: mutedGray, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
        ]),
      ),
    );
  }

  Widget _miniTrafficInfo(String label, int val) {
    return Column(children: [
      Text('$val', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
      Text(label, style: const TextStyle(color: mutedGray, fontSize: 9, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _sectionTitle(String t, Color textColor) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t.toUpperCase(), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)));

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: firAmber.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: firAmber, size: 18)));
  }

  String _todayTr() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Veri bulunamadı.', style: TextStyle(color: mutedGray)));
  }
}