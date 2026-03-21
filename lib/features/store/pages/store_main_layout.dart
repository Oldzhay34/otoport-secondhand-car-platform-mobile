import 'package:flutter/material.dart';
import 'store_home_page.dart';
import 'store_inbox_page.dart';
import 'store_erp_page.dart';
import 'store_listing_create_page.dart';
import 'store_profile_page.dart';
import '../widgets/store_bottom_nav_bar.dart';

class StoreMainLayout extends StatefulWidget {
  const StoreMainLayout({super.key});

  @override
  State<StoreMainLayout> createState() => _StoreMainLayoutState();
}

class _StoreMainLayoutState extends State<StoreMainLayout> {
  int _currentIndex = 2; // Başlangıçta ortadaki Home sayfası (Index 2)
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView sayesinde ekranlar arası kaydırma (Swipe) aktifleşir.
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Premium kaydırma hissi
        children: const [
          StoreInboxPage(),         // Index 0
          StoreErpPage(),           // Index 1
          StoreHomePage(),          // Index 2 (Center)
          StoreListingCreatePage(), // Index 3
          StoreProfilePage(),       // Index 4
        ],
      ),
      bottomNavigationBar: StoreBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}