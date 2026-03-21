import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/auth/models/expert_item_model.dart';
import 'package:otoport_mobile/features/auth/models/expert_report_model.dart';
import 'package:otoport_mobile/features/auth/services/expert_report_service.dart';
import 'package:otoport_mobile/features/store/model/store_listing_detail_response.dart';
import 'package:otoport_mobile/features/store/model/view_city_count_response.dart';
import '../service/store_listing_detail_service.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

class StoreListingDetailPage extends StatefulWidget {
  final int listingId;
  const StoreListingDetailPage({super.key, required this.listingId});

  @override
  State<StoreListingDetailPage> createState() => _StoreListingDetailPageState();
}

class _StoreListingDetailPageState extends State<StoreListingDetailPage> {
  final StoreListingDetailService _detailService = StoreListingDetailService();
  final ExpertReportService _expertReportService = ExpertReportService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  StoreListingDetailResponse? detail;
  List<ViewCityCountResponse> viewLocations = [];
  ExpertReportModel? expertReport;
  int selectedImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  // --- LOGIC ---
  Future<void> _loadPage() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final detailResult = await _detailService.getListingDetail(widget.listingId);
      final locationsResult = await _detailService.getViewLocations(widget.listingId);
      ExpertReportModel? report;
      try {
        report = await _expertReportService.getByListingId(widget.listingId);
      } catch (_) {
        if (detailResult.car?.id != null) {
          try { report = await _expertReportService.getByCarId(detailResult.car!.id!); } catch (_) {}
        }
      }
      if (!mounted) return;
      setState(() { detail = detailResult; viewLocations = locationsResult; expertReport = report; });
    } catch (e) {
      setState(() => errorMessage = 'Veriler alınamadı.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- UI BUILDER ---
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
            if (detail != null) ...[
              _buildHeaderCard(textColor, cardColor),
              const SizedBox(height: 20),
              _buildGalleryArea(cardColor),
              const SizedBox(height: 20),
              _buildMainInfoArea(textColor),
              _sectionTitle('Araç Bilgileri', textColor),
              _buildCarSpecsCard(textColor, cardColor),
              _sectionTitle('Analitik: Şehir Bazlı İzlenme', textColor),
              _buildAnalyticsCard(textColor, cardColor),
              _sectionTitle('Ekspertiz Raporu', textColor),
              _buildExpertReportCard(textColor, cardColor),
              const SizedBox(height: 50),
            ]
          ],
        ),
      ),
    );
  }

  // --- BİLEŞENLER ---

  Widget _buildHeaderCard(Color textColor, Color cardColor) {
    final data = detail!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: firAmber, child: Text(data.store?.storeName[0].toUpperCase() ?? 'M', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.store?.storeName ?? 'Mağaza', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16)),
              Text(data.store?.locationText ?? 'Konum Belirtilmemiş', style: const TextStyle(color: mutedGray, fontSize: 12)),
            ]),
          ),
          _statusBadge(data.status),
        ],
      ),
    );
  }
  Widget _buildGalleryArea(Color cardColor) {
    final urls = _galleryUrls();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : Colors.black12,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: PageView.builder(
                controller: _pageController,
                itemCount: urls.length,
                onPageChanged: (i) => setState(() => selectedImageIndex = i),
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => _openImagePreview(urls[i]),
                  child: Container(
                    color: isDarkMode ? darkCard : Colors.white,
                    child: Center(
                      child: Image.network(
                        urls[i],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: mutedGray,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (urls.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: i == selectedImageIndex
                          ? firAmber
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      urls[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: mutedGray,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMainInfoArea(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(detail!.title, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(_formatMoney(detail!.price, detail!.currency), style: const TextStyle(color: firAmber, fontSize: 24, fontWeight: FontWeight.w900)),
            if (detail!.negotiable) ...[
              const SizedBox(width: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: const Text('PAZARLIKLI', style: TextStyle(color: firAmber, fontSize: 10, fontWeight: FontWeight.bold))),
            ]
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            _infoChip(Icons.favorite_rounded, '${detail!.favoriteCount} Takip'),
            _infoChip(Icons.visibility_rounded, '${detail!.viewCount} Toplam İzlenme'),
            _infoChip(Icons.location_on_rounded, detail!.city),
          ],
        ),
      ],
    );
  }

  Widget _buildCarSpecsCard(Color textColor, Color cardColor) {
    final c = detail!.car;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(children: [
        _verticalSpecRow('MARKA / MODEL', '${c?.brandName} ${c?.modelName}', textColor),
        _verticalSpecRow('PAKET / DONANIM', c?.trimName ?? '—', textColor),
        _verticalSpecRow('YIL / KİLOMETRE', '${c?.year} • ${c?.kilometer} KM', textColor),
        _verticalSpecRow('VİTES / YAKIT', '${_trEnum(c?.transmission ?? "")} • ${_trEnum(c?.fuelType ?? "")}', textColor),
        _verticalSpecRow('MOTOR GÜCÜ', '${c?.engineVolumeCc}cc / ${c?.enginePowerHp}hp', textColor),
        _verticalSpecRow('KASA / RENK', '${_trEnum(c?.bodyType ?? "")} • ${c?.color}', textColor, isLast: true),
      ]),
    );
  }

  Widget _buildAnalyticsCard(Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: viewLocations.isEmpty
          ? const Center(child: Text('Henüz veri toplanmadı.', style: TextStyle(color: mutedGray, fontSize: 13)))
          : Column(children: viewLocations.map((loc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Text(loc.city.isEmpty ? 'Bilinmiyor' : loc.city, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('${loc.count}', style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          const Text('izlenme', style: TextStyle(color: mutedGray, fontSize: 11)),
        ]),
      )).toList()),
    );
  }

  Widget _buildExpertReportCard(Color textColor, Color cardColor) {
    if (expertReport == null) return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('Rapor eklenmemiş.', style: TextStyle(color: mutedGray))));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(children: [
        _verticalSpecRow('EKSPERTİZ SONUCU', _trExpertResult(expertReport!.result).toUpperCase(), firAmber),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.white10)),
        ...expertReport!.items.map((it) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(child: Text(_trExpertPart(it.part), style: TextStyle(color: textColor, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _expertStatusColor(it.status).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(_trExpertStatus(it.status).toUpperCase(), style: TextStyle(color: _expertStatusColor(it.status), fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ]),
        )),
      ]),
    );
  }

  // --- HELPERS ---

  Widget _verticalSpecRow(String label, String value, Color textColor, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w800)),
        if (!isLast) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: isDarkMode ? Colors.white10 : Colors.black12, height: 1)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final bool isActive = status.toUpperCase() == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(_trStatus(status).toUpperCase(), style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: firAmber), const SizedBox(width: 6), Text(label, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: 11, fontWeight: FontWeight.bold))]),
    );
  }

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

  Widget _sectionTitle(String t, Color textColor) => Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(t.toUpperCase(), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)));

  // --- TRANSLATORS & FORMATTERS ---
  String _normalizeImageUrl(String? path) {
    return ImageService.withFallback(path);
  }
  List<String> _galleryUrls() {
    final urls = (detail?.images ?? [])
        .map((e) => _normalizeImageUrl(e.imagePath))
        .toList();

    return urls.isEmpty ? [_normalizeImageUrl(null)] : urls;
  }
  String _formatMoney(double? v, String cur) => v == null ? '—' : '${v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2)} $cur';
  String _trStatus(String v) => {'ACTIVE':'Aktif','PASSIVE':'Pasif','SOLD':'Satıldı','DRAFT':'Taslak'}[v.toUpperCase()] ?? v;
  String _trEnum(String v) => {'AUTOMATIC':'Otomatik','MANUAL':'Manuel','DIESEL':'Dizel','GASOLINE':'Benzin','SEDAN':'Sedan','HATCHBACK':'Hatchback','SUV':'SUV'}[v.toUpperCase()] ?? v;
  String _trExpertResult(String? v) => {'CLEAN':'Temiz','MINOR':'Hafif Kusur','MAJOR':'Ağır Kusur'}[v?.toUpperCase()] ?? '—';
  String _trExpertPart(String? v) => {'HOOD':'Kaput','ROOF':'Tavan','FRONT_BUMPER':'Ön Tampon','REAR_BUMPER':'Arka Tampon','TRUNK_LID':'Bagaj'}[v?.toUpperCase()] ?? v ?? '—';
  String _trExpertStatus(String? v) => {'ORIGINAL':'Orijinal','PAINTED':'Boyalı','LOCAL_PAINT':'Lokal Boya','REPLACED':'Değişen'}[v?.toUpperCase()] ?? v ?? '—';
  Color _expertStatusColor(String? v) {
    switch(v?.toUpperCase()){ case 'REPLACED': return Colors.red; case 'PAINTED': return Colors.blue; case 'LOCAL_PAINT': return Colors.orange; case 'ORIGINAL': return Colors.green; default: return Colors.grey; }
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

  @override void dispose() { _pageController.dispose(); super.dispose(); }
}