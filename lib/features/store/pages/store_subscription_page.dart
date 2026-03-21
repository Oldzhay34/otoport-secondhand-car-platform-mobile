import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/network/dio_error_parser.dart';
import 'package:otoport_mobile/features/store/model/subscription_checkout_info_response.dart';
import 'package:otoport_mobile/features/store/model/subscription_response.dart';
import 'package:otoport_mobile/features/store/service/store_subscription_service.dart';

import '../model/subscription_model.dart';

class StoreSubscriptionPage extends StatefulWidget {
  const StoreSubscriptionPage({super.key});

  @override
  State<StoreSubscriptionPage> createState() => _StoreSubscriptionPageState();
}

class _StoreSubscriptionPageState extends State<StoreSubscriptionPage> {
  final StoreSubscriptionService _service = StoreSubscriptionService();
  final TextEditingController _addressController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  bool isPurchasing = false;
  String? errorMessage;
  List<SubscriptionPlanType> plans = [];
  SubscriptionCheckoutInfoResponse? checkoutInfo;
  SubscriptionResponse? currentSubscription;
  SubscriptionPlanType? selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _loadPage() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final results = await Future.wait([_service.getPlans(), _service.getCheckoutInfo()]);
      final fetchedPlans = results[0] as List<SubscriptionPlanType>;
      final fetchedCheckout = results[1] as SubscriptionCheckoutInfoResponse;
      final sortedPlans = [...fetchedPlans]..sort((a, b) => a.weight.compareTo(b.weight));
      if (!mounted) return;
      setState(() {
        plans = sortedPlans;
        checkoutInfo = fetchedCheckout;
        currentSubscription = fetchedCheckout.subscription;
        _addressController.text = fetchedCheckout.composedAddress;
      });
    } catch (e) {
      setState(() => errorMessage = DioErrorParser.parse(e).message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handlePay() async {
    final plan = selectedPlan; if (plan == null) return;
    if (_addressController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen geçerli bir fatura adresi girin.')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkCard,
        title: Text('Paket Onayı', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text('${plan.title} paketine geçmek istediğinizden emin misiniz?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ', style: TextStyle(color: mutedGray))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: firAmber), child: const Text('ONAYLA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirmed == true) _purchase(plan);
  }

  Future<void> _purchase(SubscriptionPlanType plan) async {
    setState(() => isPurchasing = true);
    try {
      final result = await _service.purchasePlan(plan);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${plan.title} paketi tanımlandı.')));
      setState(() { currentSubscription = result; selectedPlan = null; });
      _loadPage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DioErrorParser.parse(e).message)));
    } finally { if (mounted) setState(() => isPurchasing = false); }
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

  Color get textColor => isDarkMode ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? darkBg : const Color(0xFFF6F7FB);
    final cardColor = isDarkMode ? darkCard : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _buildFirsatLogo(),
        actions: [
          GestureDetector(
            onTap: () => setState(() => isDarkMode = !isDarkMode),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 44, height: 44, decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), shape: BoxShape.circle),
              child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 18, color: firAmber),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _loadPage,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCurrentStatusCard(cardColor),
            const SizedBox(height: 24),
            _buildActiveWarning(),
            _sectionTitle('ABONELİK PAKETLERİ'),
            ...plans.map((p) => _buildPlanCard(p, cardColor)),
            const SizedBox(height: 24),
            _buildCheckoutSection(cardColor),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(Color cardColor) {
    final sub = currentSubscription;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.stars_rounded, color: firAmber, size: 24),
            const SizedBox(width: 10),
            Text('MEVCUT DURUMUNUZ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 16),
          _statusRow('Paket Tipi', sub?.plan.apiValue ?? 'Belirlenmedi'),
          _statusRow('İlan Limiti', '${sub?.listingLimit ?? 0} Aktif İlan'),
          _statusRow('Bitiş Tarihi', _formatDateTime(sub?.endsAt)),
        ],
      ),
    );
  }

  Widget _buildActiveWarning() {
    if (checkoutInfo?.hasActivePaidPlan != true) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: firAmber.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: firAmber, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text('Aktif bir paketiniz zaten bulunuyor. Yeni paket alımı mevcut sürenizi etkileyebilir.', style: TextStyle(color: textColor, fontSize: 12, height: 1.4))),
      ]),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanType plan, Color cardColor) {
    final bool isCurrent = currentSubscription?.plan == plan;
    final bool isSelected = selectedPlan == plan;
    final Color pColor = _planColor(plan);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? firAmber : (isDarkMode ? Colors.white10 : Colors.black12), width: isSelected ? 2 : 1),
        boxShadow: isSelected ? [BoxShadow(color: firAmber.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))] : [],
      ),
      child: InkWell(
        onTap: isCurrent ? null : () => setState(() => selectedPlan = plan),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: pColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(_planIcon(plan), color: pColor, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plan.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(plan.metaText, style: const TextStyle(color: mutedGray, fontSize: 11)),
                ])),
                if (isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('MEVCUT', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(plan.newPriceText, style: TextStyle(color: isSelected ? firAmber : textColor, fontSize: 24, fontWeight: FontWeight.w900)),
                if (plan.oldPriceText.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 8, bottom: 4), child: Text(plan.oldPriceText, style: const TextStyle(color: mutedGray, fontSize: 13, decoration: TextDecoration.lineThrough))),
              ]),
              const SizedBox(height: 8),
              Text(plan.description, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ÖDEME ÖZETİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _checkoutRow('Seçilen Paket', selectedPlan?.title ?? 'Henüz seçilmedi'),
          _checkoutRow('Toplam Tutar', selectedPlan?.newPriceText ?? '0.00 TRY', isBold: true),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10)),
          Text('FATURA ADRESİ', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            maxLines: 3,
            style: TextStyle(color: textColor, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Adresinizi buraya yazın...',
              filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    final bool canPay = selectedPlan != null && _addressController.text.trim().length >= 6 && !isPurchasing;
    return Container(
      height: 56, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: canPay ? const LinearGradient(colors: [firAmber, Color(0xFFD97706)]) : null, color: canPay ? null : mutedGray.withOpacity(0.2)),
      child: ElevatedButton(
        onPressed: canPay ? _handlePay : null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: isPurchasing
            ? const CircularProgressIndicator(color: Colors.black)
            : Text('ÖDEME YAP VE AKTİVE ET', style: TextStyle(color: canPay ? Colors.black : mutedGray, fontWeight: FontWeight.w900, fontSize: 14)),
      ),
    );
  }

  // --- HELPERS ---

  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(t, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)));

  Widget _statusRow(String k, String? v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: mutedGray, fontSize: 13)), Text(v ?? '—', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13))]));

  Widget _checkoutRow(String k, String v, {bool isBold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: mutedGray, fontSize: 13)), Text(v, style: TextStyle(color: isBold ? firAmber : textColor, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: 14))]));

  Color _planColor(SubscriptionPlanType plan) {
    switch (plan) {
      case SubscriptionPlanType.free: return mutedGray;
      case SubscriptionPlanType.basic: return Colors.blueAccent;
      case SubscriptionPlanType.plus: return Colors.deepPurpleAccent;
      case SubscriptionPlanType.pro: return firAmber;
      default: return firAmber;
    }
  }

  IconData _planIcon(SubscriptionPlanType plan) {
    switch (plan) {
      case SubscriptionPlanType.free: return Icons.card_giftcard_rounded;
      case SubscriptionPlanType.basic: return Icons.rocket_launch_rounded;
      case SubscriptionPlanType.plus: return Icons.auto_awesome_rounded;
      case SubscriptionPlanType.pro: return Icons.workspace_premium_rounded;
      default: return Icons.star_rounded;
    }
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return 'Süresiz';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year}';
  }

  @override void dispose() { _addressController.dispose(); super.dispose(); }
}