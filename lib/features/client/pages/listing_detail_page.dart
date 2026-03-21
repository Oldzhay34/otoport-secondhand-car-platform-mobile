import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/network/dio_error_parser.dart';
import 'package:otoport_mobile/features/auth/models/expert_item_model.dart';
import 'package:otoport_mobile/features/auth/models/expert_report_model.dart';
import 'package:otoport_mobile/features/auth/models/listing_detail_model.dart';
import 'package:otoport_mobile/features/auth/models/listing_image_model.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/services/expert_report_service.dart';
import 'package:otoport_mobile/features/auth/services/inquiry_service.dart';
import 'package:otoport_mobile/features/auth/services/listing_service.dart';
import 'package:otoport_mobile/features/auth/services/listing_view_service.dart';
import 'package:otoport_mobile/features/auth/services/similar_listing_service.dart';
import 'package:otoport_mobile/features/client/pages/store_detail_page.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

import '../../auth/models/inquiry_message_model.dart';
import '../../auth/models/inquiry_thread_model.dart';
import '../../auth/models/inquiry_upsert_request.dart';
import '../../auth/models/similar_listing_model.dart';

class ListingDetailPage extends StatefulWidget {
  final int listingId;
  const ListingDetailPage({super.key, required this.listingId});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  // --- SERVISLER ---
  final ListingService _listingService = ListingService();
  final ExpertReportService _expertReportService = ExpertReportService();
  final InquiryService _inquiryService = InquiryService();
  final ListingViewService _listingViewService = ListingViewService();
  final SimilarListingService _similarListingService = SimilarListingService();
  final TextEditingController _messageController = TextEditingController();

  // --- TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  ListingDetailModel? detail;
  ExpertReportModel? _resolvedExpertReport;
  bool _isSendingInquiry = false;
  bool _isInquiryAuthRequired = false;
  InquiryThreadModel? _inquiryThread;
  int? _displayViewCount;
  bool _viewRegistered = false;
  List<SimilarListingModel> _similarListings = [];

  static const List<String> _allExpertParts = [
    'HOOD', 'ROOF', 'FRONT_BUMPER', 'REAR_BUMPER', 'FRONT_LEFT_FENDER',
    'FRONT_RIGHT_FENDER', 'FRONT_LEFT_DOOR', 'FRONT_RIGHT_DOOR',
    'REAR_LEFT_DOOR', 'REAR_RIGHT_DOOR', 'REAR_LEFT_FENDER',
    'REAR_RIGHT_FENDER', 'TRUNK_LID',
  ];

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // --- LOGIC ---
  Future<void> _loadPage() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final response = await _listingService.getListingDetail(widget.listingId);
      await _loadExpertFallback(response);
      if (!mounted) return;
      setState(() { detail = response; _displayViewCount = response.viewCount ?? 0; });
      await _registerViewOnce(response.id);
      await _loadInquiryThread(response);
      await _loadSimilarListings(response.id);
    } catch (e) {
      setState(() => errorMessage = 'İlan detayları yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadExpertFallback(ListingDetailModel d) async {
    if (d.expertReport != null) { _resolvedExpertReport = d.expertReport; return; }
    try { _resolvedExpertReport = await _expertReportService.getByListingId(d.id); } catch (_) {
      try { if (d.car?.id != null) _resolvedExpertReport = await _expertReportService.getByCarId(d.car!.id!); } catch (_) {}
    }
  }

  Future<void> _registerViewOnce(int id) async {
    if (_viewRegistered) return;
    try {
      await _listingViewService.registerView(id);
      setState(() { _viewRegistered = true; _displayViewCount = (_displayViewCount ?? 0) + 1; });
    } catch (_) {}
  }

  Future<void> _loadInquiryThread(ListingDetailModel d) async {
    try {
      final thread = await _inquiryService.getThreadByListing(d.id);
      setState(() => _inquiryThread = thread);
    } catch (e) {
      final parsed = DioErrorParser.parse(e);
      if (parsed.isUnauthorized) setState(() => _isInquiryAuthRequired = true);
    }
  }


  Future<void> _loadSimilarListings(int id) async {
    try { _similarListings = await _similarListingService.getSimilar(id, limit: 8); } catch (_) {}
    setState(() {});
  }

  Future<void> _sendInquiryMessage() async {
    final d = detail; if (d == null || d.store?.id == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSendingInquiry = true);
    try {
      final res = await _inquiryService.upsertInquiry(InquiryUpsertRequest(listingId: d.id, storeId: d.store!.id, message: text));
      _messageController.clear();
      setState(() { _inquiryThread = res; _isInquiryAuthRequired = false; });
    } catch (e) {
      final parsed = DioErrorParser.parse(e);
      if (parsed.isUnauthorized) setState(() => _isInquiryAuthRequired = true);
    } finally { if (mounted) setState(() => _isSendingInquiry = false); }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final d = detail;
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildFirsatLogo(),
        actions: [_buildThemeToggle(), const SizedBox(width: 12)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : Stack(
        children: [
          // ANA İÇERİK
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Mesaj paneli için alt boşluk
            children: [
              if (d != null) ...[
                Text(d.title ?? 'İlan', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 8),
                Text('${d.price ?? '—'} ${d.currency ?? 'TRY'}', style: const TextStyle(color: firAmber, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),

                _buildSleekStoreTile(d.store, textColor),
                const SizedBox(height: 16),

                // 👈 YENİ SIRALAMA: Çipler fotoğrafın üstünde
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _infoChip(Icons.location_on_rounded, d.city ?? '—'),
                    _infoChip(Icons.visibility_rounded, '${_displayViewCount ?? 0} İzlenme'),
                    if (d.negotiable) _infoChip(Icons.handshake_rounded, 'Pazarlık Var'),
                  ],
                ),
                const SizedBox(height: 16),

                _buildImageGallery(d.images),

                _sectionTitle('Araç Bilgileri', textColor),
                _buildCarDetailsSection(textColor, cardColor),

                _sectionTitle('İlan Açıklaması', textColor),
                _premiumCard(cardColor: cardColor, child: Text(d.description?.trim().isEmpty == true ? 'Açıklama bulunmuyor.' : d.description!, style: TextStyle(color: textColor, height: 1.6, fontSize: 14))),

                _sectionTitle('Ekspertiz Raporu', textColor),
                _buildExpertSection(_resolvedExpertReport ?? d.expertReport, textColor, cardColor),

                _sectionTitle('Benzer İlanlar', textColor),
                _buildSimilarSection(textColor, cardColor),
              ],
            ],
          ),

          // 👈 DİNAMİK MESAJLAŞMA PANELİ (Bottom Pull-up)
          if (d != null) _buildMessagingSheet(textColor, cardColor),
        ],
      ),
    );
  }

  // --- YENİ: Alttan Açılan Mesaj Paneli ---
  Widget _buildMessagingSheet(Color textColor, Color cardColor) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1, // Sadece "Mesaj Gönder" barı görünür
      minChildSize: 0.1,
      maxChildSize: 0.7, // Yukarı çekince ekranın %70'ini kaplar
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: mutedGray.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MAĞAZAYA SORU SOR', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                  const Icon(Icons.keyboard_arrow_up_rounded, color: mutedGray),
                ],
              ),
              const SizedBox(height: 20),
              if (_isInquiryAuthRequired)
                _buildInquiryAuthBody()
              else ...[
                if (_inquiryThread != null && _inquiryThread!.messages.isNotEmpty)
                  _buildChatHistory(),
                const SizedBox(height: 12),
                _buildMessageInput(textColor),
                const SizedBox(height: 40),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatHistory() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(16)),
      child: ListView(
        shrinkWrap: true,
        children: _inquiryThread!.messages.map((m) => _chatBubble(m)).toList(),
      ),
    );
  }

  Widget _buildMessageInput(Color textColor) {
    return Column(
      children: [
        TextField(
          controller: _messageController,
          maxLines: 3,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Mesajınızı buraya yazın...',
            hintStyle: const TextStyle(color: mutedGray),
            filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        _buildPrimaryBtn(_isSendingInquiry ? 'GÖNDERİLİYOR...' : 'MESAJI GÖNDER', _isSendingInquiry ? null : _sendInquiryMessage, icon: Icons.send_rounded),
      ],
    );
  }

  Widget _buildInquiryAuthBody() {
    return Column(
      children: [
        const Text('Soru sormak ve geçmiş mesajlarınızı görmek için giriş yapmalısınız.', textAlign: TextAlign.center, style: TextStyle(color: mutedGray, fontSize: 13)),
        const SizedBox(height: 16),
        _buildPrimaryBtn('GİRİŞ YAP', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))),
      ],
    );
  }

  // --- DİĞER BİLEŞENLER ---

  Widget _buildCarDetailsSection(Color textColor, Color cardColor) {
    final c = detail?.car; if (c == null) return const SizedBox.shrink();
    return _premiumCard(
      cardColor: cardColor,
      child: Column(
        children: [
          _horizontalInfoRow('MARKA', c.brandName ?? '—', textColor),
          _horizontalInfoRow('MODEL', c.modelName ?? '—', textColor),
          _horizontalInfoRow('PAKET', c.trimName ?? '—', textColor),
          _horizontalInfoRow('YIL', c.year?.toString() ?? '—', textColor),
          _horizontalInfoRow('KİLOMETRE', '${c.kilometer} KM', textColor),
          _horizontalInfoRow('VİTES', c.transmission ?? '—', textColor),
          _horizontalInfoRow('YAKIT', c.fuelType ?? '—', textColor),
          _horizontalInfoRow('MOTOR HACMİ', '${c.engineVolumeCc ?? '—'} CC', textColor),
          _horizontalInfoRow('MOTOR GÜCÜ', '${c.enginePowerHp ?? '—'} HP', textColor),
          _horizontalInfoRow('RENK', c.color ?? '—', textColor, isLast: true),
        ],
      ),
    );
  }

  Widget _buildExpertSection(ExpertReportModel? report, Color textColor, Color cardColor) {
    if (report == null) return _premiumCard(cardColor: cardColor, child: const Center(child: Text('Ekspertiz raporu bulunamadı.', style: TextStyle(color: mutedGray))));
    final items = _normalizeExpertItems(report);
    return _premiumCard(cardColor: cardColor, child: Column(children: [
      _dataRow('Firma', report.companyName ?? '—', textColor),
      _dataRow('Sonuç', report.result ?? '—', textColor, vColor: firAmber),
      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.white10)),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(_partName(item.part), style: TextStyle(fontSize: 13, color: textColor))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _statusBgColor(item.status), borderRadius: BorderRadius.circular(6)),
            child: Text(_statusName(item.status), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ]),
      )),
    ]));
  }

  List<ExpertItemModel> _normalizeExpertItems(ExpertReportModel r) {
    final items = r.items;
    final seen = items.map((e) => e.part?.toUpperCase()).toSet();
    final normalized = [...items, ..._allExpertParts.where((p) => !seen.contains(p)).map((p) => ExpertItemModel(part: p, status: 'ORIGINAL', note: ""))];
    normalized.sort((a, b) => _allExpertParts.indexOf(a.part!.toUpperCase()).compareTo(_allExpertParts.indexOf(b.part!.toUpperCase())));
    return normalized;
  }

  // --- YARDIMCI WIDGETLAR ---

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

  Widget _buildSleekStoreTile(dynamic store, Color textColor) {
    if (store == null) return const SizedBox.shrink();
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailPage(storeId: store.id))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: firAmber, child: Text(store.storeName?[0] ?? 'M', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(store.storeName ?? 'Mağaza', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14)),
              Text('${store.city} / ${store.district} • Satıcı Profili', style: const TextStyle(color: mutedGray, fontSize: 11)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: firAmber, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<ListingImageModel> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = ImageService.withFallback(images[index].imagePath);

          return GestureDetector(
            onTap: () {
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
                            errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.image, color: Colors.white)),
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
            },
            child: Container(
              width: 310,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: isDarkMode ? darkCard : Colors.white,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilarSection(Color textColor, Color cardColor) {
    if (_similarListings.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 255,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarListings.length,
        itemBuilder: (context, index) {
          final item = _similarListings[index];

          final titleText = [
            if ((item.brandName ?? '').trim().isNotEmpty) item.brandName!.trim(),
            if ((item.modelName ?? '').trim().isNotEmpty) item.modelName!.trim(),
            if ((item.title ?? '').trim().isNotEmpty) item.title!.trim(),
          ].join(' ');

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailPage(listingId: item.listingId),
              ),
            ),
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      ImageService.withFallback(item.coverImageUrl),
                      height: 110,
                      width: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText.isEmpty ? 'İlan' : titleText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (item.year != null) item.year.toString(),
                              if (item.kilometer != null)
                                '${item.kilometer} km',
                              if ((item.city ?? '').trim().isNotEmpty)
                                item.city!.trim(),
                            ].join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: mutedGray,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: firAmber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: firAmber.withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              '${item.price ?? '—'} ${item.currency ?? ''}',
                              style: const TextStyle(
                                color: firAmber,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _verticalInfoRow(String label, String value, Color textColor, {bool isLast = false}) {
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

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: firAmber.withOpacity(0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: firAmber),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    );
  }

  Widget _premiumCard({required Widget child, required Color cardColor}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)), child: child);
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)));
  }

  Widget _dataRow(String k, String v, Color textColor, {Color? vColor}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: mutedGray, fontSize: 13)), Text(v, style: TextStyle(color: vColor ?? textColor, fontWeight: FontWeight.bold, fontSize: 13))]));
  }

  Widget _buildPrimaryBtn(String t, VoidCallback? onTap, {IconData? icon}) {
    return Container(height: 50, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)])), child: ElevatedButton.icon(onPressed: onTap, icon: Icon(icon ?? Icons.arrow_forward, color: Colors.black, size: 18), label: Text(t, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent)));
  }
  Widget _horizontalInfoRow(String label, String value, Color textColor, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  color: mutedGray,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: isDarkMode ? Colors.white10 : Colors.black12,
              height: 1,
            ),
          ),
      ],
    );
  }

  String _partName(String? p) {
    final map = {'HOOD':'Kaput','ROOF':'Tavan','FRONT_BUMPER':'Ön Tampon','REAR_BUMPER':'Arka Tampon','FRONT_LEFT_FENDER':'Sol Ön Çamurluk','FRONT_RIGHT_FENDER':'Sağ Ön Çamurluk','FRONT_LEFT_DOOR':'Sol Ön Kapı','FRONT_RIGHT_DOOR':'Sağ Ön Kapı','REAR_LEFT_DOOR':'Sol Arka Kapı','REAR_RIGHT_DOOR':'Sağ Arka Kapı','REAR_LEFT_FENDER':'Sol Arka Çamurluk','REAR_RIGHT_FENDER':'Sağ Arka Çamurluk','TRUNK_LID':'Bagaj Kapağı'};
    return map[p?.toUpperCase()] ?? p ?? 'Parça';
  }

  String _statusName(String? s) {
    final map = {'ORIGINAL':'Orijinal','PAINTED':'Boyalı','LOCAL_PAINT':'Lokal Boya','REPLACED':'Değişen','REPAIRED':'Onarılmış','DAMAGED':'Hasarlı'};
    return map[s?.toUpperCase()] ?? 'Bilinmiyor';
  }

  Color _statusBgColor(String? s) {
    switch(s?.toUpperCase()){
      case 'ORIGINAL': return Colors.green;
      case 'PAINTED': return Colors.blue;
      case 'LOCAL_PAINT': return Colors.orange;
      case 'REPLACED': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _chatBubble(InquiryMessageModel m) {
    final isStore = m.senderType == 'STORE';
    return Align(alignment: isStore ? Alignment.centerLeft : Alignment.centerRight, child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isStore ? (isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)) : firAmber.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Text(m.content ?? '', style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : Colors.black87))));
  }
}