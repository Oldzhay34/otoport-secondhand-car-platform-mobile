import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_wal_row_dto.dart';
import 'package:otoport_mobile/features/admin/models/admin_wal_search_request.dart';
import 'package:otoport_mobile/features/admin/service/admin_wal_service.dart';
import 'package:otoport_mobile/features/admin/widgets/admin_bottom_nav_bar.dart';

class AdminWalPage extends StatefulWidget {
  const AdminWalPage({super.key});

  @override
  State<AdminWalPage> createState() => _AdminWalPageState();
}

class _AdminWalPageState extends State<AdminWalPage> {
  final AdminWalService _service = AdminWalService();

  // --- CONTROLLERLAR ---
  final TextEditingController _actorTypeController = TextEditingController();
  final TextEditingController _actorIdController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _pathContainsController = TextEditingController();
  final TextEditingController _qController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  List<AdminWalRowDto> rows = [];
  int limit = 100;
  String sort = 'desc';

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _loadRecent() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = await _service.getRecent(limit: limit, sort: sort);
      if (!mounted) return;
      setState(() => rows = data);
    } catch (e) {
      setState(() => errorMessage = 'WAL kayıtları yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _search() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = await _service.search(
        AdminWalSearchRequest(
          limit: limit, sort: sort,
          actorType: _actorTypeController.text.isEmpty ? null : _actorTypeController.text.trim(),
          actorId: int.tryParse(_actorIdController.text.trim()),
          method: _methodController.text.isEmpty ? null : _methodController.text.trim(),
          status: int.tryParse(_statusController.text.trim()),
          pathContains: _pathContainsController.text.isEmpty ? null : _pathContainsController.text.trim(),
          q: _qController.text.isEmpty ? null : _qController.text.trim(),
          from: _fromController.text.isEmpty ? null : _fromController.text.trim(),
          to: _toController.text.isEmpty ? null : _toController.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() => rows = data);
    } catch (_) {
      setState(() => errorMessage = 'Arama işlemi başarısız.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearFilters() {
    _actorTypeController.clear(); _actorIdController.clear(); _methodController.clear();
    _statusController.clear(); _pathContainsController.clear(); _qController.clear();
    _fromController.clear(); _toController.clear();
    setState(() { limit = 100; sort = 'desc'; });
    _loadRecent();
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
        onRefresh: _loadRecent,
        color: firAmber,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilterControlPanel(cardColor, textColor),
            const SizedBox(height: 24),
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('WAL DATA LOGS (${rows.length})', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
            const SizedBox(height: 12),
            if (rows.isEmpty) _buildEmptyState() else ...rows.map((r) => _buildWalRow(r, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildFilterControlPanel(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRAFİK DENETİM FİLTRELERİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _premiumTextField(_qController, 'Body Arama', 'Request/Response içinde ara...', textColor, icon: Icons.search_rounded),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumTextField(_actorTypeController, 'Aktör Tipi', 'CLIENT/STORE', textColor)),
            const SizedBox(width: 12),
            Expanded(child: _premiumTextField(_actorIdController, 'Aktör ID', '0', textColor, isNumber: true)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumTextField(_methodController, 'Metot', 'GET/POST', textColor)),
            const SizedBox(width: 12),
            Expanded(child: _premiumTextField(_statusController, 'Durum Kodu', '200', textColor, isNumber: true)),
          ]),
          const SizedBox(height: 12),
          _premiumTextField(_pathContainsController, 'Yol (Path)', '/api/...', textColor),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumTextField(_fromController, 'Başlangıç', 'ISO Date...', textColor)),
            const SizedBox(width: 12),
            Expanded(child: _premiumTextField(_toController, 'Bitiş', 'ISO Date...', textColor)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildActionBtn('SORGULA', _search, Icons.manage_search_rounded, isPrimary: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionBtn('TEMİZLE', _clearFilters, Icons.refresh_rounded, isPrimary: false)),
          ]),
        ],
      ),
    );
  }

  Widget _buildWalRow(AdminWalRowDto item, Color cardColor, Color textColor) {
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
                  Row(children: [
                    _methodBadge(item.method),
                    const SizedBox(width: 8),
                    _statusBadge(item.status),
                  ]),
                  Text(_formatDateTime(item.createdAt), style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                Text(item.path, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'monospace')),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
                _metaRow('AKTÖR', '${item.actorType} #${item.actorId ?? "-"}', textColor),
                _metaRow('IP ADRESİ', item.ipAddress.isEmpty ? '—' : item.ipAddress, textColor),
                if (item.queryString.isNotEmpty) _metaRow('QUERY', item.queryString, firAmber),

                if (item.requestBody.isNotEmpty) ...[
                  _sectionLabel('REQUEST BODY'),
                  _codeBlock(item.requestBody, textColor),
                ],
                if (item.responseBody.isNotEmpty) ...[
                  _sectionLabel('RESPONSE BODY'),
                  _codeBlock(item.responseBody, textColor),
                ],

                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white10, height: 1)),
                Row(children: [
                  if (item.hash.isNotEmpty) _miniHashChip('HASH', item.hash),
                  const SizedBox(width: 8),
                  if (item.prevHash.isNotEmpty) _miniHashChip('PREV', item.prevHash),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _methodBadge(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: firAmber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(method.toUpperCase(), style: const TextStyle(color: firAmber, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _statusBadge(int? status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status?.toString() ?? '—', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _codeBlock(String data, Color textColor) {
    return Container(
      width: double.infinity, margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Text(_clip(data, 1000), style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11, fontFamily: 'monospace', height: 1.4)),
    );
  }

  Widget _metaRow(String k, String v, Color vColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$k:', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Expanded(child: Text(v, style: TextStyle(color: vColor, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _sectionLabel(String t) => Padding(padding: const EdgeInsets.only(top: 16), child: Text(t, style: const TextStyle(color: mutedGray, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)));

  Widget _miniHashChip(String label, String hash) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(6)),
      child: Text('$label: ${_clip(hash, 12)}', style: const TextStyle(color: mutedGray, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    );
  }

  Widget _premiumTextField(TextEditingController ctrl, String label, String hint, Color txtColor, {bool isNumber = false, IconData? icon}) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: txtColor, fontSize: 13),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 11),
          hintText: hint, hintStyle: TextStyle(color: mutedGray.withOpacity(0.5)),
          prefixIcon: icon != null ? Icon(icon, color: firAmber, size: 18) : null,
          filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String txt, VoidCallback onTap, IconData icon, {required bool isPrimary}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isPrimary ? const LinearGradient(colors: [firAmber, Color(0xFFD97706)]) : null,
        color: isPrimary ? null : Colors.black.withOpacity(0.05),
        border: isPrimary ? null : Border.all(color: Colors.white10),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap, icon: Icon(icon, color: isPrimary ? Colors.black : mutedGray, size: 16),
        label: Text(txt, style: TextStyle(color: isPrimary ? Colors.black : mutedGray, fontWeight: FontWeight.w900, fontSize: 12)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.all(50), child: Text('Kayıtlı veri trafiği bulunamadı.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))));
  }

  // --- FORMATTERS ---
  Color _getStatusColor(int? s) {
    if (s == null) return mutedGray;
    if (s >= 500) return Colors.red;
    if (s >= 400) return Colors.orange;
    if (s >= 300) return Colors.blueAccent;
    if (s >= 200) return Colors.green;
    return mutedGray;
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _clip(String t, int m) => t.length > m ? '${t.substring(0, m)}...' : t;

  @override void dispose() {
    _actorTypeController.dispose(); _actorIdController.dispose(); _methodController.dispose();
    _statusController.dispose(); _pathContainsController.dispose(); _qController.dispose();
    _fromController.dispose(); _toController.dispose(); super.dispose();
  }
}