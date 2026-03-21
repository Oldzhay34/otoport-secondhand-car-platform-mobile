import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/models/admin_event_row_dto.dart';
import 'package:otoport_mobile/features/admin/service/admin_event_log_service.dart';
import 'package:otoport_mobile/features/admin/widgets/admin_bottom_nav_bar.dart';

class AdminEventLogPage extends StatefulWidget {
  const AdminEventLogPage({super.key});

  @override
  State<AdminEventLogPage> createState() => _AdminEventLogPageState();
}

class _AdminEventLogPageState extends State<AdminEventLogPage> {
  final AdminEventLogService _service = AdminEventLogService();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  // --- CONTROLLERLAR ---
  final TextEditingController _qController = TextEditingController();
  final TextEditingController _entityTypeController = TextEditingController();
  final TextEditingController _entityIdController = TextEditingController();
  final TextEditingController _correlationIdController = TextEditingController();

  // --- STATE ---
  bool isLoading = true;
  String? errorMessage;
  List<AdminEventRowDto> rows = [];
  String sort = 'desc';
  int limit = 200;
  String? selectedType;
  String? selectedSeverity;
  String? selectedSource;

  final List<String> severities = const ['INFO', 'WARN', 'ERROR', 'CRITICAL'];
  final List<String> sources = const ['APP', 'DOCKER', 'UPTIME', 'BACKUP', 'REDIS', 'DB', 'SECURITY'];
  final List<String> types = const ['RATE_LIMITER_FAIL_OPEN', 'RATE_LIMIT_BLOCKED', 'BACKUP_SUCCESS', 'BACKUP_FAILED', 'UPTIME_DOWN', 'UPTIME_UP', 'HEALTHCHECK_FAILED', 'CONTAINER_RESTARTED', 'DEPLOY_FINISHED'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // --- LOGIC (EKSİKSİZ KORUNDU) ---
  Future<void> _load() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final hasFilters = selectedType != null || selectedSeverity != null || selectedSource != null || _entityTypeController.text.isNotEmpty || _entityIdController.text.isNotEmpty || _correlationIdController.text.isNotEmpty || _qController.text.isNotEmpty;
      final data = hasFilters
          ? await _service.search(
        type: selectedType, severity: selectedSeverity, source: selectedSource,
        entityType: _entityTypeController.text.isEmpty ? null : _entityTypeController.text.trim(),
        entityId: int.tryParse(_entityIdController.text.trim()),
        correlationId: _correlationIdController.text.isEmpty ? null : _correlationIdController.text.trim(),
        q: _qController.text.isEmpty ? null : _qController.text.trim(),
        limit: limit, sort: sort,
      )
          : await _service.getRecent(limit: limit, sort: sort);
      if (!mounted) return;
      setState(() => rows = data);
    } catch (e) {
      setState(() => errorMessage = 'Sistem logları yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearFilters() {
    _qController.clear(); _entityTypeController.clear(); _entityIdController.clear(); _correlationIdController.clear();
    setState(() { selectedType = null; selectedSeverity = null; selectedSource = null; sort = 'desc'; limit = 200; });
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
            _buildFilterControlPanel(cardColor, textColor),
            const SizedBox(height: 24),
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: firAmber, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('SİSTEM OLAYLARI (${rows.length})', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Spacer(),
              Text('Limit: $limit', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            if (rows.isEmpty) _buildEmptyState() else ...rows.map((r) => _buildEventRow(r, cardColor, textColor)),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterControlPanel(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SİSTEM FİLTRELERİ', style: TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _premiumTextField(_qController, 'Genel Arama', 'Hata başlığı veya detay...', textColor, icon: Icons.search_rounded),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumDropdown<String>(selectedSeverity, severities, (v) => setState(() => selectedSeverity = v), (v) => v, textColor, cardColor, 'Kritiklik')),
            const SizedBox(width: 12),
            Expanded(child: _premiumDropdown<String>(selectedSource, sources, (v) => setState(() => selectedSource = v), (v) => v, textColor, cardColor, 'Kaynak')),
          ]),
          const SizedBox(height: 12),
          _premiumDropdown<String>(selectedType, types, (v) => setState(() => selectedType = v), (v) => v, textColor, cardColor, 'Olay Tipi'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _premiumTextField(_entityTypeController, 'Entity', 'Örn: CAR', textColor)),
            const SizedBox(width: 12),
            Expanded(child: _premiumTextField(_correlationIdController, 'Correlation ID', 'UUID...', textColor)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildActionBtn('SORGULA', _load, Icons.analytics_outlined, isPrimary: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionBtn('TEMİZLE', _clearFilters, Icons.refresh_rounded, isPrimary: false)),
          ]),
        ],
      ),
    );
  }

  Widget _buildEventRow(AdminEventRowDto item, Color cardColor, Color textColor) {
    final Color sevColor = _getSeverityColor(item.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  _severityBadge(item.severity, sevColor),
                  Text(_formatDateTime(item.createdAt), style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                Text(item.title.isEmpty ? 'İsimsiz Olay' : item.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 15)),
                if (item.details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(item.details, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12, height: 1.4)),
                ],
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
                _metaRow('KAYNAK', item.source, textColor),
                _metaRow('TİP', item.type, textColor),
                _metaRow('ENTITY', '${item.entityType} #${item.entityId ?? "-"}', textColor),
                _metaRow('CORRELATION', item.correlationId.isEmpty ? '—' : item.correlationId, textColor, isTechnical: true),
                _metaRow('IP ADRESİ', item.ipAddress.isEmpty ? '—' : item.ipAddress, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _severityBadge(String sev, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(sev.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _metaRow(String k, String v, Color textColor, {bool isTechnical = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$k:', style: const TextStyle(color: mutedGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Expanded(child: Text(v, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: isTechnical ? 'monospace' : null), overflow: TextOverflow.ellipsis)),
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
        items: [const DropdownMenuItem(value: null, child: Text('TÜMÜ')), ...items.map((e) => DropdownMenuItem(value: e, child: Text(labelB(e))))],
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
    return Center(child: Padding(padding: const EdgeInsets.all(50), child: Text('Kayıtlı olay bulunamadı.', style: TextStyle(color: mutedGray, fontWeight: FontWeight.bold))));
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Color _getSeverityColor(String s) {
    switch (s.toUpperCase()) {
      case 'CRITICAL': return Colors.red;
      case 'ERROR': return Colors.redAccent;
      case 'WARN': return Colors.orange;
      case 'INFO': return Colors.blueAccent;
      default: return mutedGray;
    }
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: firAmber.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: firAmber, size: 18)));
  }

  @override void dispose() { _qController.dispose(); _entityTypeController.dispose(); _entityIdController.dispose(); _correlationIdController.dispose(); super.dispose(); }
}