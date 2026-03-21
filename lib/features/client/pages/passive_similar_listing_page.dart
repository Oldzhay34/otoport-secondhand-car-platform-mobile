import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/client/pages/favorites_guest_gate_page.dart';
import 'package:otoport_mobile/features/auth/services/favorite_service.dart';

import '../../auth/models/passive_similar_listing_model.dart';
import 'listing_detail_page.dart';

class PassiveSimilarListingsPage extends StatefulWidget {
  final int listingId;
  final int limit;
  final String? title;

  const PassiveSimilarListingsPage({
    super.key,
    required this.listingId,
    this.limit = 12,
    this.title,
  });

  @override
  State<PassiveSimilarListingsPage> createState() =>
      _PassiveSimilarListingsPageState();
}

class _PassiveSimilarListingsPageState
    extends State<PassiveSimilarListingsPage> {
  final FavoriteService _favoriteService = FavoriteService();

  // --- PREMIUM TEMA RENKLERİ ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  bool isLoading = true;
  String? errorMessage;
  List<PassiveSimilarListingModel> items = [];

  @override
  void initState() {
    super.initState();
    _loadSimilar();
  }

  Future<void> _loadSimilar() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _favoriteService.getSimilarListings(
        widget.listingId,
        limit: widget.limit,
      );

      if (!mounted) return;
      setState(() {
        items = result;
      });
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FavoritesGuestGatePage()),
        );
        return;
      }
      setState(() => errorMessage = 'Benzer ilanlar yüklenemedi.');
    } catch (e) {
      setState(() => errorMessage = 'Beklenmedik bir hata oluştu.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- YARDIMCI MANTIKLAR ---
  String _formatPrice(PassiveSimilarListingModel item) {
    if (item.price == null) return '—';
    return '${item.price} ${item.currency ?? 'TRY'}';
  }

  String _buildSubtitle(PassiveSimilarListingModel item) {
    final parts = <String>[];
    if ((item.brandName ?? '').isNotEmpty) parts.add(item.brandName!);
    if ((item.modelName ?? '').isNotEmpty) parts.add(item.modelName!);
    if (item.year != null) parts.add(item.year.toString());
    if (item.kilometer != null) parts.add('${item.kilometer} km');
    if ((item.city ?? '').isNotEmpty) parts.add(item.city!);
    return parts.isEmpty ? '—' : parts.join(' • ');
  }

  void _openListing(PassiveSimilarListingModel item) {
    if (item.listingId == null || item.listingId! <= 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingDetailPage(listingId: item.listingId!)),
    );
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

  void _showDetail(PassiveSimilarListingModel item) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? darkCard : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? darkBg : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: mutedGray.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(item.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                const SizedBox(height: 8),
                Text(_buildSubtitle(item), style: const TextStyle(color: mutedGray, fontSize: 13)),
                const SizedBox(height: 20),

                // Bilgi Kartı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                  ),
                  child: Column(
                    children: [
                      _detailRow('Fiyat', _formatPrice(item)),
                      _detailRow('Marka / Model', '${item.brandName ?? '—'} ${item.modelName ?? '—'}'),
                      _detailRow('Yıl', item.year?.toString() ?? '—'),
                      _detailRow('Kilometre', item.kilometer != null ? '${item.kilometer} km' : '—'),
                      _detailRow('Şehir', item.city ?? '—'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildPrimaryBtn('İLANIN DETAYINA GİT', () {
                  Navigator.pop(context);
                  _openListing(item);
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: mutedGray, fontSize: 13)),
          Text(v, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPrimaryBtn(String txt, VoidCallback? onTap) {
    return Container(
      height: 52, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]),
        boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: Text(txt, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
      ),
    );
  }

  Widget _buildCard(PassiveSimilarListingModel item) {
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        onTap: () => _showDetail(item),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Alanı
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty
                    ? Image.network(
                  item.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black12, child: const Icon(Icons.image_not_supported, color: mutedGray)),
                )
                    : Container(color: Colors.black12, child: const Icon(Icons.directions_car_filled, size: 40, color: mutedGray)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(_buildSubtitle(item), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: mutedGray, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatPrice(item), style: const TextStyle(color: firAmber, fontSize: 18, fontWeight: FontWeight.w900)),
                      Icon(Icons.arrow_forward_ios_rounded, color: firAmber.withOpacity(0.8), size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final pageTitle = widget.title?.trim().isNotEmpty == true ? widget.title! : 'BENZER FIRSATLAR';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _buildFirsatLogo(),
        actions: [_buildThemeToggle(), const SizedBox(width: 12)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text(pageTitle.toUpperCase(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: firAmber));
    if (errorMessage != null) return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)));
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSimilar,
        color: firAmber,
        child: ListView(children: const [SizedBox(height: 140), Center(child: Text('Kriterlere uygun benzer ilan bulunamadı.', style: TextStyle(color: mutedGray)))]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSimilar,
      color: firAmber,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildCard(items[index]),
      ),
    );
  }
}