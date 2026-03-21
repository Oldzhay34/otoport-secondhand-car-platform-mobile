import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/store/model/old_listing_card_dto.dart';
import '../service/store_listing_management_service.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

class StoreOldListingsPage extends StatefulWidget {
  const StoreOldListingsPage({super.key});

  @override
  State<StoreOldListingsPage> createState() => _StoreOldListingsPageState();
}

class _StoreOldListingsPageState extends State<StoreOldListingsPage> {
  final StoreListingManagementService _service = StoreListingManagementService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  List<OldListingCardDto> items = [];

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _loadPage() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _service.getOldListings();
      if (!mounted) return;
      setState(() { items = result; });
    } catch (e) {
      setState(() => errorMessage = 'Eski ilanlar şu an yüklenemiyor.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _restoreItem(OldListingCardDto item) async {
    if (item.id == null) return;
    try {
      final ok = await _service.restore(item.id!);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan başarıyla geri yüklendi.')));
        _loadPage();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geri yükleme işlemi başarısız.')));
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
        onRefresh: _loadPage,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('ARŞİVLENMİŞ İLANLAR', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
            const SizedBox(height: 16),
            if (items.isEmpty) _buildEmptyState() else ...items.map((it) => _buildRestoreCard(it, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreCard(OldListingCardDto item, Color cardColor, Color textColor) {
    final imageUrl = _normalizeImageUrl(item.coverImageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openImagePreview(imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 80,
                        color: Colors.black12,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: mutedGray,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title.isEmpty ? 'İsimsiz İlan' : item.title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: firAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: firAmber.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _formatMoney(item.price, item.currency),
                          style: const TextStyle(
                            color: firAmber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (item.year != null) _miniChip('${item.year}', false),
                          if (item.kilometer != null)
                            _miniChip('${item.kilometer} km', false),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.deletedAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_toggle_off_rounded,
                    size: 12,
                    color: mutedGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Silinme Tarihi: ${_formatDateTime(item.deletedAt)}',
                    style: const TextStyle(color: mutedGray, fontSize: 10),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: _buildPrimaryBtn(
              'İLANINI GERİ YÜKLE',
                  () => _restoreItem(item),
              icon: Icons.restore_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _miniChip(String label, bool highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: highlight ? firAmber.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: highlight ? firAmber : mutedGray, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPrimaryBtn(String txt, VoidCallback onTap, {IconData? icon}) {
    return Container(
      height: 44, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)])),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black, size: 16),
        label: Text(txt, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(children: [
          Icon(Icons.archive_outlined, size: 64, color: mutedGray.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Arşivlenmiş ilanınız bulunmuyor.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold)),
        ]),
      ),
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
}