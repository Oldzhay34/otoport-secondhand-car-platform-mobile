import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_report_item_dto.dart';
import 'package:otoport_mobile/features/admin/service/admin_message_report_service.dart';

class AdminMessageReportsPage extends StatefulWidget {
  const AdminMessageReportsPage({super.key});

  @override
  State<AdminMessageReportsPage> createState() => _AdminMessageReportsPageState();
}

class _AdminMessageReportsPageState extends State<AdminMessageReportsPage> {
  final AdminMessageReportService _service = AdminMessageReportService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  String selectedStatus = '';
  List<AdminReportItemDto> items = [];

  final List<String> statuses = const ['', 'OPEN', 'IN_REVIEW', 'RESOLVED', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // --- LOGIC (EKSİKSİZ) ---
  Future<void> _load() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = await _service.getAll(status: selectedStatus.isEmpty ? null : selectedStatus);
      if (!mounted) return;
      setState(() => items = data);
    } catch (e) {
      setState(() => errorMessage = 'Raporlar şu an yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _setStatus(AdminReportItemDto item, String newStatus) async {
    if (item.id == null) return;
    try {
      await _service.setStatus(reportId: item.id!, status: newStatus);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapor durumu güncellendi.')));
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İşlem başarısız.')));
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
          IconButton(icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: firAmber), onPressed: () => setState(() => isDarkMode = !isDarkMode)),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _load,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildModerationHeader(cardColor, textColor),
            const SizedBox(height: 24),
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('MESAJ RAPORLARI (${items.length})', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
            const SizedBox(height: 12),
            if (items.isEmpty) _buildEmptyState() else ...items.map((it) => _buildReportCard(it, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationHeader(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MODERASYON MERKEZİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                Text('Raporları Filtrele', style: TextStyle(color: mutedGray, fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
              _buildCircleAction(Icons.refresh_rounded, _load),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                dropdownColor: cardColor,
                isExpanded: true,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.isEmpty ? 'TÜM DURUMLAR' : _trStatus(s)))).toList(),
                onChanged: (v) { setState(() => selectedStatus = v!); _load(); },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(AdminReportItemDto item, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _statusBadge(item.status),
                  Text(_formatDateTime(item.createdAt), style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
                ]),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),

                _metaRow('NEDEN', item.reason.toUpperCase(), firAmber),
                _metaRow('GÖNDEREN', item.senderType, textColor),
                _metaRow('RAPORLAYAN', '${item.reporterType} #${item.reporterId ?? "-"}', textColor),

                const SizedBox(height: 16),
                Text('RAPORLANAN MESAJ', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                  child: Text(item.messageText.isEmpty ? '—' : item.messageText, style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 13, height: 1.4)),
                ),
                if (item.details.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('EK DETAYLAR', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold, fontSize: 10)),
                  Text(item.details, style: TextStyle(color: textColor, fontSize: 12)),
                ],
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  _miniChip('Store #${item.storeId}'),
                  _miniChip('Inquiry #${item.inquiryId}'),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(
              children: [
                _smallActionBtn('ÇÖZÜLDÜ', Icons.check_circle_outline, Colors.green, () => _setStatus(item, 'RESOLVED')),
                _smallActionBtn('REDDET', Icons.cancel_outlined, Colors.redAccent, () => _setStatus(item, 'REJECTED')),
                _smallActionBtn('İNCELE', Icons.manage_search_rounded, Colors.blueAccent, () => _setStatus(item, 'IN_REVIEW')),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _statusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(_trStatus(status), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _metaRow(String k, String v, Color vColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$k:', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Text(v, style: TextStyle(color: vColor, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _miniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _smallActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: firAmber.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: firAmber, size: 18)));
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.all(50), child: Text('Şu an bekleyen rapor bulunmuyor.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))));
  }

  // --- HELPERS (FORMATTERS) ---
  Color _getStatusColor(String s) {
    switch (s.toUpperCase()) {
      case 'OPEN': return Colors.orange;
      case 'IN_REVIEW': return Colors.blueAccent;
      case 'RESOLVED': return Colors.green;
      case 'REJECTED': return Colors.redAccent;
      default: return mutedGray;
    }
  }

  String _trStatus(String s) => {
    'OPEN':'AÇIK', 'IN_REVIEW':'İNCELENİYOR', 'RESOLVED':'ÇÖZÜLDÜ', 'REJECTED':'REDDEDİLDİ'
  }[s.toUpperCase()] ?? s;

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}