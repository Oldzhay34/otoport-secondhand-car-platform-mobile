import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth/models/store_listing_card_model.dart';
import '../../auth/models/store_public_model.dart';
import '../../auth/services/store_public_service.dart';
import 'package:otoport_mobile/features/client/pages/listing_detail_page.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

class StoreDetailPage extends StatefulWidget {
  final int storeId;
  const StoreDetailPage({super.key, required this.storeId});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  final StorePublicService _storeService = StorePublicService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  bool isLoading = true;
  String? errorMessage;
  StorePublicModel? store;
  List<StoreListingCardModel> listings = [];

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
      final storeResponse = await _storeService.getStore(widget.storeId);
      final listingsResponse = await _storeService.getStoreListings(widget.storeId);
      setState(() {
        store = storeResponse;
        listings = listingsResponse;
      });
    } catch (e) {
      setState(() => errorMessage = 'Mağaza bilgileri alınamadı.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- UI BİLEŞENLERİ ---

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

  Widget _premiumCard({required Widget child, required Color cardColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  Widget _buildStoreHeader(Color textColor, Color cardColor) {
    final s = store;
    if (s == null) return const SizedBox.shrink();

    final logoUrl = ImageService.toPublicUrl(s.logoUrl);

    return Column(
      children: [
        _premiumCard(
          cardColor: cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Ortalamak daha estetik durur
                children: [
                  // ✅ ANA LOGO KUTUSU
                  GestureDetector(
                    onTap: logoUrl == null ? null : () => _openImagePreview(logoUrl),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white, // Logonun net görünmesi için beyaz zemin
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: logoUrl != null
                            ? Image.network(
                          logoUrl,
                          fit: BoxFit.contain, // Logo kesilmesin diye contain
                          errorBuilder: (_, __, ___) => _buildInitialLogo(s),
                        )
                            : _buildInitialLogo(s),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ✅ ARKA PLANI BLURLU METİN ALANI
                  Expanded(
                    child: Container(
                      height: 72,
                      clipBehavior: Clip.antiAlias, // Blur dışarı taşmasın
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                      ),
                      child: Stack(
                        children: [
                          // 1. Katman: Bulanık Resim
                          if (logoUrl != null)
                            Positioned.fill(
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur şiddeti
                                child: Opacity(
                                  opacity: 0.25, // Görseldeki gibi hafif görünürlük
                                  child: Image.network(
                                    logoUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                          // 2. Katman: Hafif Karartma/Aydınlatma (Okunabilirlik için)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.black.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),

                          // 3. Katman: İçerik (İsim ve Konum)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.storeName ?? 'Mağaza',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: firAmber),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${s.city ?? '—'} / ${s.district ?? '—'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.6),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Onaylı Kurumsal Mağaza Rozeti
              if (s.verified) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'ONAYLI KURUMSAL MAĞAZA',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white10, height: 1),
              ),

              _dataRow('Telefon', s.phone ?? '—', textColor),
              _dataRow('Web Sitesi', s.website ?? '—', textColor),
              _dataRow('Adres', s.addressLine ?? '—', textColor),
            ],
          ),
        ),
      ],
    );
  }

// Logo yüklenemezse gösterilecek yardımcı widget
  Widget _buildInitialLogo(StorePublicModel s) {
    return Center(
      child: Text(
        (s.storeName != null && s.storeName!.isNotEmpty)
            ? s.storeName![0].toUpperCase()
            : 'M',
        style: const TextStyle(
          color: firAmber,
          fontWeight: FontWeight.w900,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildListingCard(
      StoreListingCardModel item,
      Color cardColor,
      Color textColor,
      ) {
    final imageUrl = ImageService.withFallback(item.imageUrl);

    final title = (item.title != null && item.title!.trim().isNotEmpty)
        ? item.title!
        : '${item.brand ?? ''} ${item.model ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(listingId: item.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ GÖRSEL
              GestureDetector(
                onTap: () => _openImagePreview(imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    imageUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 92,
                      height: 92,
                      color: firAmber.withOpacity(0.08),
                      child: const Icon(Icons.image, color: firAmber),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ✅ BURASI FIX
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // 🔥 EN ÖNEMLİ FIX
                  children: [
                    Text(
                      title.isEmpty ? 'İlan' : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      '${item.year ?? '—'} • ${item.brand ?? '—'} • ${item.model ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedGray,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ✅ FİYAT
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
                        '${item.price ?? '—'} TL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: firAmber,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: mutedGray,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final storeName = store?.storeName ?? 'MAĞAZA DETAYI';

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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (errorMessage != null) Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent))),

            _buildStoreHeader(textColor, cardColor),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktif İlanlar', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('${listings.length} İlan', style: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),

            if (listings.isEmpty)
              _premiumCard(cardColor: cardColor, child: const Center(child: Text('Mağazaya ait aktif ilan bulunamadı.', style: TextStyle(color: mutedGray))))
            else
              ...listings.map((item) => _buildListingCard(item, cardColor, textColor)),

            const SizedBox(height: 40),
            Center(child: Text('© FIRSAT', style: TextStyle(color: mutedGray, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI METODLAR ---

  Widget _dataRow(String k, String v, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: mutedGray, fontSize: 13)),
          Expanded(child: Text(v, textAlign: TextAlign.right, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
