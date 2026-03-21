import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/store/model/store_inquiry_list_item_dto.dart';
import 'package:otoport_mobile/features/store/pages/store_inquiry_thread_page.dart';
import '../service/store_inquiry_service.dart';

class StoreInboxPage extends StatefulWidget {
  const StoreInboxPage({super.key});

  @override
  State<StoreInboxPage> createState() => _StoreInboxPageState();
}

class _StoreInboxPageState extends State<StoreInboxPage> {
  final StoreInquiryService _service = StoreInquiryService();
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
  List<StoreInquiryListItemDto> items = [];
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // --- LOGIC (EKSİKSİZ) ---
  Future<void> _initializePage() async {
    await Future.wait([
      _loadItems(),
      _loadUnreadCount(),
    ]);
  }

  Future<void> _loadItems({String? q}) async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _service.getInquiries(q: q);
      if (!mounted) return;
      setState(() { items = result; });
    } catch (e) {
      setState(() => errorMessage = 'Mesajlar yüklenemedi.');
    } finally {
      if (mounted) setState(() { isLoading = false; isSearching = false; });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      setState(() => unreadCount = count);
    } catch (_) {}
  }

  Future<void> _search() async {
    setState(() => isSearching = true);
    await Future.wait([
      _loadItems(q: _searchController.text.trim()),
      _loadUnreadCount(),
    ]);
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
          IconButton(icon: const Icon(Icons.refresh_rounded, color: mutedGray), onPressed: _initializePage),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Özet Paneli
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MESAJ MERKEZİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text('Toplam ${items.length} Görüşme • $unreadCount Okunmamış', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: firAmber, shape: BoxShape.circle),
                      child: Text('$unreadCount', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ),

          // 2. Arama Kartı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBox(cardColor, textColor),
          ),
          const SizedBox(height: 12),

          // 3. Mesaj Listesi
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: firAmber))
                : RefreshIndicator(
              onRefresh: _initializePage,
              color: firAmber,
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildInquiryCard(items[index], cardColor, textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(Color cardColor, Color textColor) {
    return Container(
      height: 54,
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: mutedGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(hintText: 'Müşteri veya ilan ara...', hintStyle: TextStyle(color: mutedGray.withOpacity(0.7)), border: InputBorder.none),
            ),
          ),
          if (isSearching)
            const Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: firAmber)))
          else
            IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: firAmber), onPressed: _search),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(StoreInquiryListItemDto item, Color cardColor, Color textColor) {
    final bool isUnread = item.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread ? firAmber.withOpacity(isDarkMode ? 0.05 : 0.08) : cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread ? firAmber.withOpacity(0.4) : (isDarkMode ? Colors.white10 : Colors.black12),
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: item.inquiryId == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreInquiryThreadPage(inquiryId: item.inquiryId!))).then((_) => _initializePage()),
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isUnread ? firAmber : (isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
              child: Text(item.displayName.isNotEmpty ? item.displayName[0].toUpperCase() : 'M', style: TextStyle(color: isUnread ? Colors.black : firAmber, fontWeight: FontWeight.w900)),
            ),
            if (isUnread)
              Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: firAmber, shape: BoxShape.circle, border: Border.all(color: isDarkMode ? darkCard : Colors.white, width: 2)))),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(item.listingTitle.isEmpty ? 'İsimsiz İlan' : item.listingTitle, style: TextStyle(color: textColor, fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(_formatDateTime(item.lastSentAt), style: const TextStyle(color: mutedGray, fontSize: 10)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.displayName, style: TextStyle(color: isUnread ? firAmber : mutedGray, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(item.lastMessage.isEmpty ? 'Görsel paylaşıldı...' : item.lastMessage, style: TextStyle(color: isUnread ? textColor : mutedGray, fontSize: 13, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                _miniStatusTag(item.status),
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  _miniUnreadBadge(item.unreadCount),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: mutedGray),
      ),
    );
  }

  Widget _miniStatusTag(String status) {
    final bool isOpen = status.trim().toUpperCase() == 'OPEN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: isOpen ? Colors.green.withOpacity(0.1) : Colors.black12, borderRadius: BorderRadius.circular(6)),
      child: Text(isOpen ? 'AKTİF' : 'KAPALI', style: TextStyle(color: isOpen ? Colors.green : mutedGray, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _miniUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(6)),
      child: Text('$count YENİ MESAJ', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: mutedGray.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Henüz bir mesajlaşma bulunmuyor.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    final now = DateTime.now();
    if (l.day == now.day && l.month == now.month && l.year == now.year) {
      return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
    }
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}';
  }

  @override void dispose() { _searchController.dispose(); super.dispose(); }
}