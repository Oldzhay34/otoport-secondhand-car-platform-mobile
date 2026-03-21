import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/admin/pages/admin_audit_log_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_event_log_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_home_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_notification_create_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_store_subscription_page.dart';
import 'package:otoport_mobile/features/admin/pages/admin_wal_page.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  // --- PREMIUM TEMA RENKLERİ ---
  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);

  void _go(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0: page = const AdminAuditLogPage(); break;
      case 1: page = const AdminEventLogPage(); break;
      case 2: page = const AdminHomePage(); break;
      case 3: page = const AdminWalPage(); break;
      case 4: page = const AdminNotificationCreatePage(); break;
      case 5: page = const AdminStoreSubscriptionPage(); break;
      default: page = const AdminHomePage();
    }

    // Navigasyon geçişini daha yumuşak (Fade) yapmak istersen bu şekilde kullanabilirsin
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? darkCard.withOpacity(0.9) : Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(context, 0, Icons.assignment_outlined, Icons.assignment_rounded, "Audit"),
                  _navItem(context, 1, Icons.report_gmailerrorred_rounded, Icons.report_problem_rounded, "Event"),
                  _centerHomeItem(context), // Home Sayfası
                  _navItem(context, 3, Icons.terminal_outlined, Icons.terminal_rounded, "WAL"),
                  _navItem(context, 4, Icons.notification_add_outlined, Icons.notification_add_rounded, "Notif"),
                  _navItem(context, 5, Icons.inventory_2_outlined, Icons.inventory_2_rounded, "Paket"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? firAmber : mutedGray;

    return InkWell(
      onTap: () => _go(context, index),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? firAmber.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          // Aktif sekme göstergesi (alt çizgi)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: isSelected ? 12 : 0,
            decoration: BoxDecoration(
              color: firAmber,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                if (isSelected) BoxShadow(color: firAmber.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerHomeItem(BuildContext context) {
    final bool isSelected = currentIndex == 2;

    return InkWell(
      onTap: () => _go(context, 2),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [firAmber, const Color(0xFFD97706)]
                : [mutedGray.withOpacity(0.2), mutedGray.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(
              color: firAmber.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Icon(
          isSelected ? Icons.home_rounded : Icons.home_outlined,
          color: isSelected ? Colors.black : mutedGray,
          size: 24,
        ),
      ),
    );
  }
}