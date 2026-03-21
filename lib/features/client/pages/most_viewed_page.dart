import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otoport_mobile/core/services/image_service.dart';
import 'package:otoport_mobile/features/auth/models/most_viewed_listing_model.dart';
import 'package:otoport_mobile/features/auth/services/most_viewed_service.dart';
import 'package:otoport_mobile/features/client/pages/listing_detail_page.dart';

class MostViewedPage extends StatefulWidget {
  const MostViewedPage({super.key});

  @override
  State<MostViewedPage> createState() => _MostViewedPageState();
}

class _MostViewedPageState extends State<MostViewedPage> {
  final MostViewedService _service = MostViewedService();

  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);

  bool isDarkMode = true;
  bool isLoading = true;
  String? errorMessage;

  List<MostViewedListingModel> items = [];

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _service.getMostViewed(limit: 20);

      if (!mounted) return;

      setState(() {
        items = response.items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Trend ilanlar yüklenemedi: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

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
          style: const TextStyle(
            fontSize: 16,
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: firAmber,
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _normalizeImageUrl(String? path) {
    return ImageService.withFallback(path);
  }

  String _formatPrice(double? price, String? currency) {
    if (price == null) return 'Fiyat bilgisi yok';

    final formatted = NumberFormat('#,##0', 'tr_TR').format(price);
    return '$formatted ${currency ?? 'TRY'}';
  }

  String _formatKm(int? km) {
    if (km == null) return '—';
    return '${NumberFormat('#,##0', 'tr_TR').format(km)} km';
  }

  String _formatLocation(MostViewedListingModel item) {
    final parts = [
      if ((item.city ?? '').trim().isNotEmpty) item.city!.trim(),
      if ((item.district ?? '').trim().isNotEmpty) item.district!.trim(),
    ];

    return parts.isEmpty ? 'Konum bilgisi yok' : parts.join(' / ');
  }

  Widget _statChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: firAmber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: firAmber),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: firAmber,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(
      MostViewedListingModel item,
      Color cardColor,
      Color textColor,
      int index,
      ) {
    final imageUrl = _normalizeImageUrl(item.coverImageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: firAmber.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: item.id == null
            ? null
            : () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(listingId: item.id!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
                  child: SizedBox(
                    height: 185,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: mutedGray,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: firAmber.withOpacity(0.35)),
                    ),
                    child: Text(
                      '#${index + 1} Trend',
                      style: const TextStyle(
                        color: firAmber,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((item.storeName ?? '').trim().isNotEmpty) ...[
                    Text(
                      item.storeName!.trim(),
                      style: const TextStyle(
                        color: mutedGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatPrice(item.price, item.currency),
                    style: const TextStyle(
                      color: firAmber,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.year != null) _statChip(icon: Icons.calendar_month_rounded, text: '${item.year}'),
                      _statChip(icon: Icons.speed_rounded, text: _formatKm(item.kilometer)),
                      _statChip(icon: Icons.visibility_rounded, text: '${item.viewCount ?? 0}'),
                      _statChip(icon: Icons.favorite_rounded, text: '${item.favoriteCount ?? 0}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatLocation(item),
                    style: const TextStyle(
                      color: mutedGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((item.brand ?? '').trim().isNotEmpty ||
                      (item.model ?? '').trim().isNotEmpty ||
                      (item.engine ?? '').trim().isNotEmpty ||
                      (item.pack ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      [
                        if ((item.brand ?? '').trim().isNotEmpty) item.brand!.trim(),
                        if ((item.model ?? '').trim().isNotEmpty) item.model!.trim(),
                        if ((item.engine ?? '').trim().isNotEmpty) item.engine!.trim(),
                        if ((item.pack ?? '').trim().isNotEmpty) item.pack!.trim(),
                      ].join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (item.negotiable) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: firAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: firAmber.withOpacity(0.25)),
                      ),
                      child: const Text(
                        'Pazarlık Var',
                        style: TextStyle(
                          color: firAmber,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(Color cardColor, Color textColor) {
    if (errorMessage != null) {
      return [
        const SizedBox(height: 16),
        Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ];
    }

    if (!isLoading && items.isEmpty) {
      return const [
        SizedBox(height: 40),
        Center(
          child: Text(
            'Trend ilan bulunamadı.',
            style: TextStyle(color: mutedGray),
          ),
        ),
      ];
    }

    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Trend İlanlar',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              '${items.length} ilan',
              style: const TextStyle(
                color: firAmber,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ...List.generate(
        items.length,
            (index) => _buildListingCard(
          items[index],
          cardColor,
          textColor,
          index,
        ),
      ),
    ];
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
        title: _buildFirsatLogo(),
        actions: [
          _buildThemeToggle(),
          const SizedBox(width: 12),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: firAmber),
      )
          : RefreshIndicator(
        onRefresh: _loadPage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _buildBody(cardColor, textColor),
        ),
      ),
    );
  }
}