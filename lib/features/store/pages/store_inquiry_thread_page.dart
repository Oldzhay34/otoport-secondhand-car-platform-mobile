import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/store/model/inquiry_reply_request.dart';
import 'package:otoport_mobile/features/store/model/message_report_request.dart';
import 'package:otoport_mobile/features/store/model/store_inquiry_message_dto.dart';
import 'package:otoport_mobile/features/store/model/store_inquiry_thread_response.dart';
import 'package:otoport_mobile/features/store/pages/store_listing_detail_page.dart';
import '../service/store_inquiry_service.dart';

class StoreInquiryThreadPage extends StatefulWidget {
  final int inquiryId;
  const StoreInquiryThreadPage({super.key, required this.inquiryId});

  @override
  State<StoreInquiryThreadPage> createState() => _StoreInquiryThreadPageState();
}

class _StoreInquiryThreadPageState extends State<StoreInquiryThreadPage> {
  final StoreInquiryService _service = StoreInquiryService();
  final TextEditingController _replyController = TextEditingController();

  // --- PREMIUM TEMA ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);
  bool isDarkMode = true;

  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  StoreInquiryThreadResponse? thread;

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  // --- LOGIC (EKSİKSİZ) ---
  Future<void> _loadThread() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await _service.getThread(widget.inquiryId);
      await _service.markRead(widget.inquiryId).catchError((_) {});
      if (!mounted) return;
      setState(() { thread = result; });
    } catch (e) {
      setState(() => errorMessage = 'Mesajlar yüklenemedi.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    setState(() => isSending = true);
    try {
      await _service.reply(widget.inquiryId, InquiryReplyRequest(message: text));
      _replyController.clear();
      await _loadThread();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesaj gönderilemedi.')));
    } finally {
      if (mounted) setState(() => isSending = false);
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
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadThread,
              color: firAmber,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (thread != null) _buildHeaderCard(thread!, cardColor, textColor),
                  const SizedBox(height: 24),
                  if (thread != null) ...thread!.messages.map((m) => _buildMessageBubble(m, textColor)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildInputArea(cardColor, textColor),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(StoreInquiryThreadResponse data, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(data.listingTitle.isEmpty ? 'İlan Görüşmesi' : data.listingTitle, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900))),
              _statusBadge(data.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: firAmber.withOpacity(0.1), child: Text(data.displayName[0], style: const TextStyle(color: firAmber, fontWeight: FontWeight.bold))),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.displayName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(_formatDateTime(data.createdAt), style: const TextStyle(color: mutedGray, fontSize: 11)),
                ],
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10, height: 1)),
          if (data.clientEmail.isNotEmpty) _contactRow(Icons.email_outlined, data.clientEmail),
          if (data.guestPhone.isNotEmpty) _contactRow(Icons.phone_android_outlined, data.guestPhone),
          const SizedBox(height: 16),
          _buildPrimaryBtn('İLANIN DETAYLARINA GİT', () {
            if (data.listingId != null) Navigator.push(context, MaterialPageRoute(builder: (_) => StoreListingDetailPage(listingId: data.listingId!)));
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(StoreInquiryMessageDto item, Color textColor) {
    final bool isStore = item.isStoreSender;
    return Align(
      alignment: isStore ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isStore ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isStore ? firAmber : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isStore ? 16 : 0),
                bottomRight: Radius.circular(isStore ? 0 : 16),
              ),
            ),
            child: Text(
              item.content.trim(),
              style: TextStyle(color: isStore ? Colors.black : textColor, fontSize: 14, fontWeight: isStore ? FontWeight.w600 : FontWeight.normal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_formatDateTime(item.sentAt), style: const TextStyle(color: mutedGray, fontSize: 10)),
                if (!isStore) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _reportMessage(item),
                    child: const Text('Rapor Et', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(color: cardColor, border: Border(top: BorderSide(color: isDarkMode ? Colors.white10 : Colors.black12))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: _replyController,
                maxLines: 4, minLines: 1,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Cevabınızı yazın...', hintStyle: TextStyle(color: mutedGray), border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isSending ? null : _sendReply,
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 10)]),
              child: isSending
                  ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)))
                  : const Icon(Icons.send_rounded, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _statusBadge(String status) {
    final bool isOpen = status.trim().toUpperCase() == 'OPEN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isOpen ? Colors.green.withOpacity(0.1) : Colors.black12, borderRadius: BorderRadius.circular(8)),
      child: Text(isOpen ? 'AÇIK' : 'KAPALI', style: TextStyle(color: isOpen ? Colors.green : mutedGray, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _contactRow(IconData icon, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [Icon(icon, size: 14, color: mutedGray), const SizedBox(width: 8), Text(val, style: const TextStyle(color: mutedGray, fontSize: 12))]),
    );
  }

  Widget _buildPrimaryBtn(String t, VoidCallback onTap) {
    return Container(
      height: 48, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: firAmber.withOpacity(0.5))),
      child: TextButton(onPressed: onTap, child: Text(t, style: const TextStyle(color: firAmber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5))),
    );
  }

  String _formatDateTime(DateTime? v) {
    if (v == null) return '—';
    final l = v.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _reportMessage(StoreInquiryMessageDto message) async {
    // Orijinal raporlama diyaloğu mantığı (Themer ile güncellendi)
    final result = await showDialog<_ReportDialogResult>(context: context, builder: (_) => const _ReportDialog());
    if (result == null) return;
    try {
      await _service.reportMessage(inquiryId: widget.inquiryId, messageId: message.id!, request: MessageReportRequest(reason: result.reason, details: result.details));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesaj raporlandı.')));
    } catch (_) {}
  }
}

// --- RAPORLAMA DİYALOĞU (TEMA UYUMLU) ---
class _ReportDialog extends StatefulWidget {
  const _ReportDialog();
  @override State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final TextEditingController _detailsController = TextEditingController();
  String _selectedReason = 'OFFENSIVE';
  static const List<Map<String, String>> _reasons = [{'value': 'OFFENSIVE', 'label': 'Uygunsuz İçerik'},{'value': 'SPAM', 'label': 'Spam'},{'value': 'FRAUD', 'label': 'Dolandırıcılık'},{'value': 'OTHER', 'label': 'Diğer'}];

  @override Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF171A21),
      title: const Text('Mesajı Rapor Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedReason,
            dropdownColor: const Color(0xFF171A21),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Neden', labelStyle: TextStyle(color: Color(0xFFFFB020))),
            items: _reasons.map((e) => DropdownMenuItem(value: e['value']!, child: Text(e['label']!))).toList(),
            onChanged: (v) => setState(() => _selectedReason = v!),
          ),
          TextField(controller: _detailsController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Detaylar')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('VAZGEÇ', style: TextStyle(color: Colors.grey))),
        ElevatedButton(onPressed: () => Navigator.pop(context, _ReportDialogResult(reason: _selectedReason, details: _detailsController.text)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB020)), child: const Text('RAPORLA', style: TextStyle(color: Colors.black))),
      ],
    );
  }
}

class _ReportDialogResult {
  final String reason; final String details;
  const _ReportDialogResult({required this.reason, required this.details});
}