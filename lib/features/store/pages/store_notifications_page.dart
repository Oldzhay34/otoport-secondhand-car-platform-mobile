import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/store/model/store_notification_dto.dart';
import '../service/store_notification_service.dart';

class StoreNotificationsPage extends StatefulWidget {
  const StoreNotificationsPage({super.key});

  @override
  State<StoreNotificationsPage> createState() => _StoreNotificationsPageState();
}

class _StoreNotificationsPageState extends State<StoreNotificationsPage> {
  final StoreNotificationService _notificationService = StoreNotificationService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  bool unreadOnly = false;
  bool isMarkingAll = false;
  String? errorMessage;
  List<StoreNotificationDto> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // --- LOGIC (EKSİKSİZ) ---
  Future<void> _loadNotifications() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _notificationService.getNotifications(
        unreadOnly: unreadOnly ? true : null,
      );
      if (!mounted) return;
      setState(() { notifications = result; });
    } catch (e) {
      setState(() => errorMessage = 'Bildirimler şu an yüklenemiyor.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _markRead(StoreNotificationDto item) async {
    if (item.id == null || item.isRead) return;
    try {
      await _notificationService.markRead(item.id!);
      _loadNotifications();
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    setState(() => isMarkingAll = true);
    try {
      await _notificationService.markAllRead();
      await _loadNotifications();
    } finally {
      if (mounted) setState(() => isMarkingAll = false);
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
        actions: [_buildThemeToggle(), const SizedBox(width: 12)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryHeader(cardColor, textColor),
            const SizedBox(height: 20),
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('BİLDİRİM GEÇMİŞİ', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
            const SizedBox(height: 12),
            if (notifications.isEmpty) _buildEmptyState() else ...notifications.map((n) => _buildNotificationCard(n, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(Color cardColor, Color textColor) {
    final unreadCount = notifications.where((e) => !e.isRead).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MAĞAZA BİLDİRİMLERİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text('$unreadCount Yeni Bildiriminiz Var', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              _buildCircleAction(Icons.done_all_rounded, isMarkingAll ? null : _markAllRead),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10, height: 1)),
          SwitchListTile(
            title: Text('Sadece Okunmamışları Göster', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
            activeColor: firAmber,
            value: unreadOnly,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) { setState(() => unreadOnly = val); _loadNotifications(); },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(StoreNotificationDto item, Color cardColor, Color textColor) {
    final Color typeColor = _typeColor(item.type);
    final bool isUnread = !item.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? firAmber.withOpacity(isDarkMode ? 0.05 : 0.08) : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnread ? firAmber.withOpacity(0.4) : (isDarkMode ? Colors.white10 : Colors.black12), width: isUnread ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: () => _markRead(item),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(_typeIcon(item.type), color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.title.isEmpty ? 'Sistem Bildirimi' : item.title, style: TextStyle(color: textColor, fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(item.message, style: TextStyle(color: isUnread ? textColor.withOpacity(0.9) : mutedGray, fontSize: 13, height: 1.4)),
                    ]),
                  ),
                  if (isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: firAmber, shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _metaChip(item.type.isEmpty ? 'GENEL' : item.type, isUnread),
                  const SizedBox(width: 8),
                  _metaChip(_formatDateTime(item.createdAt), false),
                ],
              ),
              if (item.payloadJson.isNotEmpty) ...[
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('SİSTEM DETAYLARI', style: TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(item.payloadJson, style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _metaChip(String label, bool highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
      child: Text(label.toUpperCase(), style: TextStyle(color: highlight ? firAmber : mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: firAmber.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: firAmber.withOpacity(0.3))),
        child: isMarkingAll
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: firAmber, strokeWidth: 2))
            : Icon(icon, color: firAmber, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(children: [
          Icon(Icons.notifications_off_rounded, size: 64, color: mutedGray.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Henüz bir bildiriminiz yok.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Color _typeColor(String type) {
    final t = type.toUpperCase();
    if (t.contains('INQUIRY')) return Colors.blueAccent;
    if (t.contains('LISTING')) return firAmber;
    if (t.contains('PACKAGE')) return Colors.purpleAccent;
    if (t.contains('PAYMENT')) return Colors.greenAccent;
    return mutedGray;
  }

  IconData _typeIcon(String type) {
    final t = type.toUpperCase();
    if (t.contains('INQUIRY')) return Icons.mail_rounded;
    if (t.contains('LISTING')) return Icons.directions_car_rounded;
    if (t.contains('PACKAGE')) return Icons.workspace_premium_rounded;
    if (t.contains('PAYMENT')) return Icons.payments_rounded;
    return Icons.notifications_active_rounded;
  }
}