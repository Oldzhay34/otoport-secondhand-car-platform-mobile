import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth/models/client_notification_model.dart';
import '../../auth/services/client_notifications_service.dart';
import 'listing_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ClientNotificationService _notificationService = ClientNotificationService();

  // --- PREMIUM TEMA RENKLERİ ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  bool isLoading = true;
  bool onlyUnread = false;
  String? errorMessage;

  int unreadCount = 0;
  List<ClientNotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final count = await _notificationService.getUnreadCount();
      final list = await _notificationService.getNotifications(onlyUnread: onlyUnread);

      setState(() {
        unreadCount = count;
        notifications = list;
      });
    } catch (e) {
      setState(() => errorMessage = 'Bildirimler yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleRead(ClientNotificationModel item) async {
    if (item.id == null) return;
    try {
      await _notificationService.markRead(notificationId: item.id!, isRead: !item.isRead);
      await _refreshAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İşlem başarısız oldu.')));
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _notificationService.markAllRead();
      await _refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm bildirimler okundu işaretlendi.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata oluştu.')));
    }
  }

  // --- UI BİLEŞENLERİ ---

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

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        width: 50, height: 28, padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(15)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: firAmber),
            child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ClientNotificationModel item, Color textColor, Color cardColor) {
    final bool isUnread = !item.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUnread ? firAmber.withOpacity(isDarkMode ? 0.05 : 0.08) : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? firAmber.withOpacity(0.4) : (isDarkMode ? Colors.white10 : Colors.black12),
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: isUnread ? [BoxShadow(color: firAmber.withOpacity(0.1), blurRadius: 10)] : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: isUnread ? firAmber : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
            color: isUnread ? Colors.black : mutedGray,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: textColor,
            fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              item.message,
              style: TextStyle(color: isUnread ? textColor.withOpacity(0.9) : mutedGray, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniChip(item.createdAt ?? '—', isUnread),
                const SizedBox(width: 8),
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(6)),
                    child: const Text('YENİ', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: mutedGray),
          color: isDarkMode ? darkCard : Colors.white,
          onSelected: (value) {
            if (value == 'toggle') _toggleRead(item);
            if (value == 'listing' && item.listingId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailPage(listingId: item.listingId!),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(item.isRead ? 'Okunmadı Yap' : 'Okundu Yap', style: TextStyle(color: textColor, fontSize: 13)),
            ),
            PopupMenuItem(
              value: 'listing',
              child: Text('İlana Git', style: TextStyle(color: textColor, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, bool highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: highlight ? firAmber : mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
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
          IconButton(onPressed: _refreshAll, icon: const Icon(Icons.refresh_rounded, color: mutedGray)),
          IconButton(onPressed: _markAllRead, icon: const Icon(Icons.done_all_rounded, color: firAmber)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Üst Özet Paneli
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [firAmber, firAmber.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BİLDİRİM MERKEZİ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text('$unreadCount Yeni Bildirim', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 30),
                ],
              ),
            ),
          ),

          // Filtreleme
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile(
              title: Text('Sadece Okunmamışlar', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
              activeColor: firAmber,
              value: onlyUnread,
              onChanged: (value) {
                setState(() => onlyUnread = value);
                _refreshAll();
              },
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: firAmber))
                : errorMessage != null
                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                : notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _refreshAll,
              color: firAmber,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) => _buildCard(notifications[index], textColor, cardColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: mutedGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Henüz yeni bir bildirim yok.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}