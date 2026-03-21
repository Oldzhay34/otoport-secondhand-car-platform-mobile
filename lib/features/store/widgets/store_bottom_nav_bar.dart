import 'package:flutter/material.dart';

class StoreBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StoreBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color firAmber = Color(0xFFFFB020);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A21) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, "Mesaj"),
              _navItem(1, Icons.analytics_outlined, Icons.analytics_rounded, "ERP"),
              _centerItem(), // Dashboard - Tam Orta
              _navItem(3, Icons.add_box_outlined, Icons.add_box_rounded, "İlan Ver"),
              _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, "Profil"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? firAmber.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? firAmber : Colors.grey,
              size: 24,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? firAmber : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerItem() {
    final isSelected = currentIndex == 2;
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [firAmber, Color(0xFFD97706)]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: firAmber.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(
          isSelected ? Icons.dashboard_rounded : Icons.dashboard_outlined,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}