import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:otoport_mobile/features/client/pages/favorites_guest_gate_page.dart';
import 'package:otoport_mobile/features/client/pages/passive_similar_listing_page.dart';
import '../../auth/models/favorite_car_model.dart';
import '../../auth/services/favorite_service.dart';
import 'package:otoport_mobile/core/services/image_service.dart';
import 'listing_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FavoriteService _favoriteService = FavoriteService();
  final TextEditingController _searchController = TextEditingController();

  // --- PREMIUM TEMA VE RENKLER ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  bool isLoading = true;
  String? errorMessage;

  List<FavoriteCardModel> activeFavorites = [];
  List<FavoriteCardModel> passiveFavorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadAll() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final active = await _favoriteService.getMyFavorites();
      final passive = await _favoriteService.getMyPassiveFavorites();

      setState(() {
        activeFavorites = active;
        passiveFavorites = passive;
      });
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritesGuestGatePage()));
        return;
      }
      setState(() => errorMessage = 'Favoriler yüklenemedi: ${e.message}');
    } catch (e) {
      setState(() => errorMessage = 'Beklenmedik bir hata oluştu.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- YARDIMCI MANTIKLAR ---
  List<FavoriteCardModel> _filterList(List<FavoriteCardModel> list) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((item) => item.title.toLowerCase().contains(q) || (item.city ?? '').toLowerCase().contains(q)).toList();
  }

  String _formatPrice(FavoriteCardModel item) {
    if (item.price == null) return '—';
    return '${item.price} ${item.currency ?? 'TL'}';
  }

  String _buildSubtitle(FavoriteCardModel item) {
    final parts = <String>[];
    if (item.year != null) parts.add(item.year.toString());
    if (item.kilometer != null) parts.add('${item.kilometer} km');
    if ((item.city ?? '').isNotEmpty) parts.add(item.city!);
    return parts.isEmpty ? '—' : parts.join(' • ');
  }

  Future<void> _removeFavorite(int listingId) async {
    try {
      await _favoriteService.removeFavorite(listingId);
      await _loadAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favoriden kaldırıldı.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaldırma işlemi başarısız.')));
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
          child: Container(width: 22, height: 22, decoration: const BoxDecoration(shape: BoxShape.circle, color: firAmber), child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 14, color: Colors.black)),
        ),
      ),
    );
  }

  void _showDetail(FavoriteCardModel item, {required bool passive}) {
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: isDarkMode ? darkBg : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: mutedGray.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(item.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                const SizedBox(height: 8),
                Text(passive ? 'İlan yayında değil.' : _buildSubtitle(item), style: const TextStyle(color: mutedGray)),
                const SizedBox(height: 20),

                // Detay Kutusu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
                  child: Column(
                    children: [
                      _buildDetailRow('Fiyat', passive ? '—' : _formatPrice(item)),
                      _buildDetailRow('Konum', item.city ?? '—'),
                      _buildDetailRow('Marka', item.brand ?? '—'),
                      _buildDetailRow('Model', item.model ?? '—'),
                      _buildDetailRow('Mağaza', item.storeName ?? '—'),
                      _buildDetailRow('Görüntülenme', (item.viewCount ?? 0).toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildPrimaryBtn(passive ? 'Benzer İlanlar' : 'İlana Git', () {
                      Navigator.pop(context);
                      if (passive) {
                        Navigator.push(this.context, MaterialPageRoute(builder: (_) => PassiveSimilarListingsPage(listingId: item.listingId!, title: 'Benzer İlanlar')));
                      } else {
                        Navigator.push(this.context, MaterialPageRoute(builder: (_) => ListingDetailPage(listingId: item.listingId!)));
                      }
                    })),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSecondaryBtn('Kaldır', () async {
                      Navigator.pop(context);
                      await _removeFavorite(item.listingId!);
                    })),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: mutedGray, fontSize: 13)),
          Text(v, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPrimaryBtn(String txt, VoidCallback onTap) {
    return Container(
      height: 50,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)])),
      child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), child: Text(txt, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
    );
  }

  Widget _buildSecondaryBtn(String txt, VoidCallback onTap) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(side: const BorderSide(color: firAmber), foregroundColor: firAmber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildFavoriteCard(FavoriteCardModel item, {required bool passive}) {
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: ListTile(
        onTap: () => _showDetail(item, passive: passive),
        contentPadding: const EdgeInsets.all(12),
        leading: GestureDetector(
          onTap: () {
            final imageUrl = ImageService.withFallback(item.imagePath);
            _openImagePreview(imageUrl);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ImageService.withFallback(item.imagePath),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: firAmber.withOpacity(0.1),
                child: const Icon(Icons.image, color: firAmber),
              ),
            ),
          ),
        ),
        title: Text(item.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(passive ? 'Yayında Değil' : _buildSubtitle(item), style: TextStyle(color: passive ? Colors.redAccent : mutedGray, fontSize: 12)),
            const SizedBox(height: 4),
            Text(passive ? '—' : _formatPrice(item), style: TextStyle(color: firAmber, fontWeight: FontWeight.w900)),
          ],
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: mutedGray), onPressed: () => _removeFavorite(item.listingId!)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final activeCount = _filterList(activeFavorites).length;
    final passiveCount = _filterList(passiveFavorites).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildFirsatLogo(),
        actions: [_buildThemeToggle(), const SizedBox(width: 12)],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: firAmber,
          labelColor: firAmber,
          unselectedLabelColor: mutedGray,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: [Tab(text: 'Aktif ($activeCount)'), Tab(text: 'Pasif ($passiveCount)')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Favorilerde ara...',
                hintStyle: const TextStyle(color: mutedGray),
                prefixIcon: const Icon(Icons.search, color: firAmber),
                filled: true,
                fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: firAmber))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildList(activeFavorites, passive: false),
                _buildList(passiveFavorites, passive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<FavoriteCardModel> items, {required bool passive}) {
    final filtered = _filterList(items);
    if (filtered.isEmpty) {
      return RefreshIndicator(onRefresh: _loadAll, child: ListView(children: [const SizedBox(height: 100), Center(child: Text('Kayıt bulunamadı.', style: TextStyle(color: mutedGray)))]));
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildFavoriteCard(filtered[index], passive: passive),
      ),
    );
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}