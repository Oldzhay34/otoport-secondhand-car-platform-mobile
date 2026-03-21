import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_audit_row_dto.dart';
import 'package:otoport_mobile/features/admin/service/admin_audit_log_service.dart';

class AdminAuditLogPage extends StatefulWidget {
  const AdminAuditLogPage({super.key});

  @override
  State<AdminAuditLogPage> createState() => _AdminAuditLogPageState();
}

class _AdminAuditLogPageState extends State<AdminAuditLogPage> {
  final AdminAuditLogService _service = AdminAuditLogService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- CONTROLLERLAR ---
  final TextEditingController _qController = TextEditingController();
  final TextEditingController _actorIdController = TextEditingController();
  final TextEditingController _entityIdController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _entityTypeController = TextEditingController();

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  List<AdminAuditRowDto> rows = [];
  String sort = 'desc';
  int limit = 200;
  String? actorType;
  final List<String> actorTypes = const ['CLIENT', 'STORE', 'ADMIN', 'GUEST'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _load() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      List<AdminAuditRowDto> data;
      final hasFilter = actorType != null || _actorIdController.text.isNotEmpty || _entityIdController.text.isNotEmpty || _actionController.text.isNotEmpty || _entityTypeController.text.isNotEmpty || _qController.text.isNotEmpty;

      if (hasFilter) {
        data = await _service.search(
          actorType: actorType, actorId: int.tryParse(_actorIdController.text.trim()),
          action: _actionController.text.isEmpty ? null : _actionController.text.trim(),
          entityType: _entityTypeController.text.isEmpty ? null : _entityTypeController.text.trim(),
          entityId: int.tryParse(_entityIdController.text.trim()),
          q: _qController.text.isEmpty ? null : _qController.text.trim(),
          limit: limit, sort: sort,
        );
      } else {
        data = await _service.getRecent(limit: limit, sort: sort);
      }
      if (!mounted) return;
      setState(() => rows = data);
    } catch (e) {
      setState(() => errorMessage = 'Kayıtlar yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearFilters() {
    _qController.clear(); _actorIdController.clear(); _entityIdController.clear();
    _actionController.clear(); _entityTypeController.clear();
    setState(() { actorType = null; sort = 'desc'; limit = 200; });
    _load();
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
            _buildFilterSection(cardColor, textColor),
            const SizedBox(height: 24),
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('AUDIT FEED (${rows.length})', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Spacer(),
              Text('Sıralama: ${sort.toUpperCase()}', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            if (rows.isEmpty) _buildEmptyState() else ...rows.map((r) => _buildAuditRow(r, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DENETİM FİLTRELERİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _premiumTextField(_qController, 'Genel Arama', 'Aksiyon, detay veya IP ara...', textColor, icon: Icons.search_rounded),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumDropdown<String>(actorType, ['TÜMÜ', ...actorTypes], (v) => setState(() => actorType = v == 'TÜMÜ' ? null : v), (v) => v, textColor, cardColor, 'Aktör Tipi')),
            const SizedBox(width: 12),
            Expanded(child: _premiumTextField(_actorIdController, 'Aktör ID', '0', textColor, isNumber: true)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumTextField(_actionController, 'Aksiyon', 'Örn: CREATE', textColor)),
            const SizedBox(width: 12),
            Expanded(child: _premiumTextField(_entityTypeController, 'Entity Tipi', 'Örn: CAR', textColor)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildActionBtn('UYGULA', _load, Icons.done_all_rounded, isPrimary: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionBtn('TEMİZLE', _clearFilters, Icons.clear_all_rounded, isPrimary: false)),
          ]),
        ],
      ),
    );
  }

  Widget _buildAuditRow(AdminAuditRowDto item, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: firAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(item.action.toUpperCase(), style: const TextStyle(color: firAmber, fontSize: 10, fontWeight: FontWeight.w900))),
            Text(_formatDateTime(item.createdAt), style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
          _metaDataRow('AKTÖR', '${item.actorType} #${item.actorId ?? "-"}', textColor),
          _metaDataRow('HEDEF', '${item.entityType} #${item.entityId ?? "-"}', textColor),
          _metaDataRow('IP ADRESİ', item.ipAddress.isEmpty ? '—' : item.ipAddress, textColor),
          if (item.details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text(item.details, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12, height: 1.4)),
            ),
          ],
          const SizedBox(height: 10),
          Text(_clip(item.userAgent, 120), style: const TextStyle(color: mutedGray, fontSize: 9, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _metaDataRow(String k, String v, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$k:', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Text(v, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _premiumTextField(TextEditingController ctrl, String label, String hint, Color txtColor, {bool isNumber = false, IconData? icon}) {
    return SizedBox(
      height: 50,
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

  Widget _premiumDropdown<T>(T? val, List<T> items, Function(T?) onChg, String Function(T) labelB, Color txtColor, Color bg, String label) {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<T>(
        value: val, dropdownColor: bg,
        style: TextStyle(color: txtColor, fontSize: 13),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: firAmber, fontWeight: FontWeight.bold, fontSize: 11), filled: true, fillColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelB(e)))).toList(),
        onChanged: onChg,
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
    return Center(child: Padding(padding: const EdgeInsets.all(50), child: Text('Kriterlere uygun kayıt bulunamadı.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))));
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _clip(String t, int m) => t.length > m ? '${t.substring(0, m)}...' : t;

  @override void dispose() { _qController.dispose(); _actorIdController.dispose(); _entityIdController.dispose(); _actionController.dispose(); _entityTypeController.dispose(); super.dispose(); }
}