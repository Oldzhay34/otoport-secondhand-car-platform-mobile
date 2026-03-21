import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/constants/api_constants.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';
import 'package:otoport_mobile/features/client/pages/client_profile_page.dart';
import 'package:otoport_mobile/features/client/pages/favorites_guest_gate_page.dart';
import 'package:otoport_mobile/features/client/pages/most_viewed_page.dart';

import '../../auth/models/home_store_filters_response.dart';
import '../../auth/models/home_store_model.dart';
import '../../auth/services/client_notifications_service.dart';
import '../../auth/services/home_service.dart';
import 'favorites_page.dart';
import 'filter_listings_page.dart';
import 'notifications_page.dart';
import 'package:otoport_mobile/features/client/pages/store_detail_page.dart';

class ClientHomePage extends StatefulWidget {
  final bool isGuest;
  const ClientHomePage({super.key, required this.isGuest});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final HomeService _homeService = HomeService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final ClientNotificationService _notificationService =
  ClientNotificationService();

  final Dio _catalogDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);

  bool isDarkMode = true;
  bool isLoading = true;
  bool actualGuest = true;
  bool showCarFilter = true;

  String? errorMessage;

  List<HomeStoreModel> stores = [];
  List<String> cities = [];
  List<String> districts = [];
  List<BuildingOption> buildings = [];
  List<String> floors = [];

  String selectedCity = '';
  String selectedDistrict = '';
  String selectedBuildingId = '';
  String selectedFloor = '';

  int unreadNotificationCount = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _yearMinController = TextEditingController();
  final TextEditingController _yearMaxController = TextEditingController();
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();
  final TextEditingController _kmMinController = TextEditingController();
  final TextEditingController _kmMaxController = TextEditingController();

  String selectedBrand = '';
  String selectedModel = '';
  String selectedVariant = '';
  String selectedEngine = '';
  String selectedPack = '';
  String selectedBodyType = '';

  Map<String, dynamic>? _catalogData;
  bool _isCatalogLoading = false;

  List<String> brandOptions = [];
  List<String> modelOptions = [];
  List<String> variantOptions = [];
  List<String> engineOptions = [];
  List<String> packageOptions = [];

  Map<String, dynamic>? _selectedBrandObj;
  Map<String, dynamic>? _selectedModelObj;
  Map<String, dynamic>? _selectedVariantObj;
  Map<String, dynamic>? _selectedEngineObj;

  static const List<Map<String, String>> bodyTypeOptions = [
    {'value': 'BINEK', 'label': 'Binek'},
    {'value': 'SEDAN', 'label': 'Sedan'},
    {'value': 'HATCHBACK', 'label': 'Hatchback'},
    {'value': 'SUV', 'label': 'SUV'},
    {'value': 'COUPE', 'label': 'Coupe'},
    {'value': 'STATION_WAGON', 'label': 'Station Wagon'},
    {'value': 'PICKUP', 'label': 'Pick-up'},
    {'value': 'VAN', 'label': 'Minivan / Panelvan'},
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      await _resolveActualUserMode();
      if (actualGuest) await _homeService.guestHit();
      await _loadFilters();
      await _loadStores();
      await _loadUnreadCount();
      await _loadCarCatalog();
    } catch (e) {
      setState(() => errorMessage = 'Veriler yüklenemedi: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resolveActualUserMode() async {
    if (widget.isGuest) {
      setState(() => actualGuest = true);
      return;
    }
    try {
      final me = await _authService.me();
      final isClient = me.authenticated &&
          (me.role?.toUpperCase().replaceFirst('ROLE_', '') == 'CLIENT');
      setState(() => actualGuest = !isClient);
    } catch (_) {
      setState(() => actualGuest = true);
    }
  }

  Future<void> _loadFilters() async {
    final response = await _homeService.getStoreFilters(
      city: selectedCity,
      district: selectedDistrict,
      buildingId: selectedBuildingId,
    );

    setState(() {
      cities = response.cities;
      districts = response.districts;
      buildings = response.buildings;
      floors = response.floors;
    });
  }

  Future<void> _loadStores() async {
    final result = await _homeService.getStores(
      limit: 50,
      city: selectedCity,
      district: selectedDistrict,
      buildingId: selectedBuildingId,
      floor: selectedFloor,
    );
    setState(() => stores = result);
  }

  Future<void> _loadUnreadCount() async {
    if (actualGuest) {
      setState(() => unreadNotificationCount = 0);
      return;
    }
    try {
      final count = await _notificationService.getUnreadCount();
      setState(() => unreadNotificationCount = count);
    } catch (_) {
      setState(() => unreadNotificationCount = 0);
    }
  }

  Future<void> _applyFilters() async {
    setState(() => isLoading = true);
    try {
      await _loadStores();
    } catch (_) {
      setState(() => errorMessage = 'Mağazalar alınamadı.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resetFilters() async {
    setState(() {
      selectedCity = '';
      selectedDistrict = '';
      selectedBuildingId = '';
      selectedFloor = '';
      isLoading = true;
    });

    try {
      await _loadFilters();
      await _loadStores();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _onCityChanged(String? value) async {
    setState(() {
      selectedCity = value ?? '';
      selectedDistrict = '';
      selectedBuildingId = '';
      selectedFloor = '';
      isLoading = true;
    });
    try {
      await _loadFilters();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _onDistrictChanged(String? value) async {
    setState(() {
      selectedDistrict = value ?? '';
      selectedBuildingId = '';
      selectedFloor = '';
      isLoading = true;
    });
    try {
      await _loadFilters();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _onBuildingChanged(String? value) async {
    setState(() {
      selectedBuildingId = value ?? '';
      selectedFloor = '';
      isLoading = true;
    });
    try {
      await _loadFilters();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      if (!actualGuest) await _authService.logout();
    } catch (_) {}
    await _tokenStorage.clearAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  String _normalizeBodyTypeForCatalog(String value) {
    final s = value.trim().toUpperCase();
    if (s.isEmpty) return 'CAR';
    if (s == 'BINEK' || s.contains('BINEK')) return 'CAR';
    if (s.contains('SUV') || s.contains('CROSSOVER')) return 'SUV';
    if (s == 'VAN' || s.contains('MINIVAN') || s.contains('PANELVAN')) {
      return 'MINIVAN';
    }
    return 'CAR';
  }

  String _getCatalogPath() {
    final key = _normalizeBodyTypeForCatalog(selectedBodyType);
    if (key == 'SUV') return '/filejson/suvwithpackages.json';
    if (key == 'MINIVAN') return '/filejson/minivanwithpackages.json';
    return '/filejson/AutomobileWithPackeages.json';
  }

  Future<void> _loadCarCatalog() async {
    setState(() => _isCatalogLoading = true);
    try {
      final response = await _catalogDio.get(_getCatalogPath());
      final data = Map<String, dynamic>.from(response.data);

      final brands = ((data['brands'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .map((e) => e['brand'].toString())
          .where((e) => e.trim().isNotEmpty)
          .toList()
        ..sort();

      if (!mounted) return;

      setState(() {
        _catalogData = data;
        brandOptions = brands;
        modelOptions = [];
        variantOptions = [];
        engineOptions = [];
        packageOptions = [];

        selectedBrand = '';
        selectedModel = '';
        selectedVariant = '';
        selectedEngine = '';
        selectedPack = '';

        _selectedBrandObj = null;
        _selectedModelObj = null;
        _selectedVariantObj = null;
        _selectedEngineObj = null;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isCatalogLoading = false);
    }
  }

  void _onBrandChanged(String? value) {
    final brand = value ?? '';
    final brands = ((_catalogData?['brands'] as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final brandObj = brands.cast<Map<String, dynamic>?>().firstWhere(
          (b) => b?['brand'].toString() == brand,
      orElse: () => null,
    );

    final models = (((brandObj?['models']) as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => e['model'].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort();

    setState(() {
      selectedBrand = brand;
      _selectedBrandObj = brandObj;

      selectedModel = '';
      selectedVariant = '';
      selectedEngine = '';
      selectedPack = '';

      _selectedModelObj = null;
      _selectedVariantObj = null;
      _selectedEngineObj = null;

      modelOptions = models;
      variantOptions = [];
      engineOptions = [];
      packageOptions = [];
    });
  }

  void _onModelChanged(String? value) {
    final model = value ?? '';
    final models = (((_selectedBrandObj?['models']) as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final modelObj = models.cast<Map<String, dynamic>?>().firstWhere(
          (m) => m?['model'].toString() == model,
      orElse: () => null,
    );

    final variants = (((modelObj?['variants']) as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => e['variant'].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort();

    final directEngines = (((modelObj?['engines']) as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => e['engine'].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort();

    setState(() {
      selectedModel = model;
      _selectedModelObj = modelObj;

      selectedVariant = '';
      selectedEngine = '';
      selectedPack = '';

      _selectedVariantObj = null;
      _selectedEngineObj = null;

      variantOptions = variants;
      engineOptions = variants.isEmpty ? directEngines : [];
      packageOptions = [];
    });
  }

  void _onVariantChanged(String? value) {
    final variant = value ?? '';
    final variants = (((_selectedModelObj?['variants']) as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final variantObj = variants.cast<Map<String, dynamic>?>().firstWhere(
          (v) => v?['variant'].toString() == variant,
      orElse: () => null,
    );

    final engines = (((variantObj?['engines']) as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => e['engine'].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort();

    final packages = (((variantObj?['packages']) as List?) ?? [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort();

    setState(() {
      selectedVariant = variant;
      _selectedVariantObj = variantObj;

      selectedEngine = '';
      selectedPack = '';
      _selectedEngineObj = null;

      engineOptions = engines;
      packageOptions = packages;
    });
  }

  void _onEngineChanged(String? value) {
    final engine = value ?? '';
    List<Map<String, dynamic>> engineArr = [];

    if (_selectedVariantObj?['engines'] is List) {
      engineArr = (_selectedVariantObj!['engines'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else if (_selectedModelObj?['engines'] is List) {
      engineArr = (_selectedModelObj!['engines'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final engineObj = engineArr.cast<Map<String, dynamic>?>().firstWhere(
          (e) => e?['engine'].toString() == engine,
      orElse: () => null,
    );

    final packages = (((engineObj?['packages']) as List?) ?? [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort();

    setState(() {
      selectedEngine = engine;
      _selectedEngineObj = engineObj;
      packageOptions = packages;
      selectedPack = '';
    });
  }

  void _onPackChanged(String? value) {
    setState(() => selectedPack = value ?? '');
  }

  Future<void> _onBodyTypeChanged(String? value) async {
    setState(() => selectedBodyType = value ?? '');
    await _loadCarCatalog();
  }

  void _resetCarFilters() {
    _searchController.clear();
    _yearMinController.clear();
    _yearMaxController.clear();
    _priceMinController.clear();
    _priceMaxController.clear();
    _kmMinController.clear();
    _kmMaxController.clear();

    setState(() {
      selectedBrand = '';
      selectedModel = '';
      selectedVariant = '';
      selectedEngine = '';
      selectedPack = '';
      selectedBodyType = '';
    });

    _loadCarCatalog();
  }

  Future<void> _goToCarFilterPage() async {
    final yearMin = int.tryParse(_yearMinController.text.trim());
    final yearMax = int.tryParse(_yearMaxController.text.trim());
    final priceMin = double.tryParse(_priceMinController.text.trim());
    final priceMax = double.tryParse(_priceMaxController.text.trim());
    final kmMin = int.tryParse(_kmMinController.text.trim());
    final kmMax = int.tryParse(_kmMaxController.text.trim());

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterListingsPage(
          q: _searchController.text.trim(),
          brand: selectedBrand,
          model: selectedModel,
          variant: selectedVariant,
          engine: selectedEngine,
          pack: selectedPack,
          bodyType: selectedBodyType,
          yearMin: yearMin,
          yearMax: yearMax,
          priceMin: priceMin,
          priceMax: priceMax,
          kmMin: kmMin,
          kmMax: kmMax,
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
          _buildThemeToggle(),
          const SizedBox(width: 10),
          if (actualGuest)
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(
                  color: firAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: _logout,
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: firAmber))
          : RefreshIndicator(
        onRefresh: _initializePage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderProfile(cardColor, textColor),
            const SizedBox(height: 20),
            _buildQuickActions(cardColor),
            const SizedBox(height: 16),
            _buildTrendListingsButton(),
            const SizedBox(height: 20),
            _buildFilterPanel(cardColor, textColor),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Öne Çıkan Mağazalar',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${stores.length} Mağaza',
                  style: const TextStyle(
                    color: mutedGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (stores.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Henüz mağaza bulunamadı.')),
              )
            else
              ...stores.map((s) => _buildStoreCard(s, cardColor, textColor)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFirsatLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: firAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: firAmber, width: 1.5),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          children: [
            TextSpan(
              text: "FIR",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const TextSpan(
              text: "SAT",
              style: TextStyle(color: firAmber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => setState(() => isDarkMode = !isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(3),
        width: 55,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment:
          isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: firAmber,
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderProfile(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: firAmber.withOpacity(0.1),
            child: Icon(
              actualGuest ? Icons.person_outline : Icons.verified_user,
              color: firAmber,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actualGuest ? 'Misafir Kullanıcı' : 'Client Paneli',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  actualGuest
                      ? 'Kısıtlı modda göz atıyorsunuz.'
                      : 'Tüm işlemleriniz aktif durumda.',
                  style: const TextStyle(
                    color: mutedGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color cardColor) {
    return Row(
      children: [
        _buildActionItem(
          Icons.favorite_rounded,
          'Favoriler',
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => actualGuest
                    ? const FavoritesGuestGatePage()
                    : const FavoritesPage(),
              ),
            );
          },
          cardColor,
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          Icons.notifications_rounded,
          'Bildirim',
              () {
            if (actualGuest) {
              _showGuestRestriction('bildirimlere');
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ).then((_) => _loadUnreadCount());
            }
          },
          cardColor,
          badge: unreadNotificationCount,
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          Icons.person_rounded,
          'Profil',
              () {
            if (actualGuest) {
              _showGuestRestriction('profiline');
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientProfilePage()),
              );
            }
          },
          cardColor,
        ),
      ],
    );
  }

  Widget _buildActionItem(
      IconData icon,
      String label,
      VoidCallback onTap,
      Color cardColor, {
        int badge = 0,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? Colors.white10 : Colors.black12,
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: firAmber, size: 28),
                  if (badge > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black26
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildToggleBtn(
                  'Araç Filtrele',
                  showCarFilter,
                      () => setState(() => showCarFilter = true),
                ),
                _buildToggleBtn(
                  'Mağaza Filtrele',
                  !showCarFilter,
                      () => setState(() => showCarFilter = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (showCarFilter) _buildCarFilterBody() else _buildStoreFilterBody(),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? firAmber : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
              BoxShadow(
                color: firAmber.withOpacity(0.3),
                blurRadius: 10,
              )
            ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: active ? Colors.black : mutedGray,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarFilterBody() {
    final selectedBodyTypeLabel = bodyTypeOptions
        .firstWhere(
          (e) => e['value'] == selectedBodyType,
      orElse: () => {'label': ''},
    )['label']!;

    return Column(
      children: [
        if (_isCatalogLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(color: firAmber),
          ),
        _buildTextField(
          _searchController,
          'Arama',
          'Mağaza, marka veya model ara...',
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          'Kasa Tipi',
          bodyTypeOptions.map((e) => e['label']!).toList(),
          selectedBodyTypeLabel,
              (v) {
            final val = bodyTypeOptions
                .firstWhere((e) => e['label'] == v)['value']!;
            _onBodyTypeChanged(val);
          },
        ),
        const SizedBox(height: 12),
        _buildDropdown('Marka', brandOptions, selectedBrand, _onBrandChanged),
        const SizedBox(height: 12),
        _buildDropdown('Model', modelOptions, selectedModel, _onModelChanged),
        const SizedBox(height: 12),
        _buildDropdown(
          'Varyant',
          variantOptions,
          selectedVariant,
          _onVariantChanged,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          'Motor',
          engineOptions,
          selectedEngine,
          _onEngineChanged,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          'Paket',
          packageOptions,
          selectedPack,
          _onPackChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _yearMinController,
                'Min Yıl',
                '2018',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _yearMaxController,
                'Max Yıl',
                '2024',
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _priceMinController,
                'Min Fiyat',
                '500000',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _priceMaxController,
                'Max Fiyat',
                '1500000',
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _kmMinController,
                'Min KM',
                '0',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _kmMaxController,
                'Max KM',
                '150000',
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildPrimaryBtn('İlanları Listele', _goToCarFilterPage),
            ),
            const SizedBox(width: 12),
            _buildCircleBtn(Icons.refresh_rounded, _resetCarFilters),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreFilterBody() {
    final selectedBuildingName = buildings
        .firstWhere(
          (e) => e.id == selectedBuildingId,
      orElse: () => BuildingOption(id: '', name: ''),
    )
        .name;

    return Column(
      children: [
        _buildDropdown('İl', cities, selectedCity, _onCityChanged),
        const SizedBox(height: 12),
        _buildDropdown('İlçe', districts, selectedDistrict, _onDistrictChanged),
        const SizedBox(height: 12),
        _buildDropdown(
          'Bina',
          buildings.map((e) => e.name).toList(),
          selectedBuildingName,
              (v) {
            final id = buildings.firstWhere((e) => e.name == v).id;
            _onBuildingChanged(id);
          },
        ),
        const SizedBox(height: 12),
        _buildDropdown('Kat', floors, selectedFloor, (v) {
          setState(() => selectedFloor = v ?? '');
        }),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildPrimaryBtn('Mağazaları Filtrele', _applyFilters),
            ),
            const SizedBox(width: 12),
            _buildCircleBtn(Icons.refresh_rounded, _resetFilters),
          ],
        )
      ],
    );
  }
  Widget _buildTrendListingsButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            firAmber.withOpacity(0.22),
            firAmber.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: firAmber.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: firAmber.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MostViewedPage(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Text(
                  '🔥',
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trend İlanlar',
                        style: TextStyle(
                          color: firAmber,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'En çok görüntülenen ilanları keşfet',
                        style: TextStyle(
                          color: mutedGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: firAmber,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint, {
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: firAmber,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: mutedGray.withOpacity(0.5)),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget _buildDropdown(
      String label,
      List<String> options,
      String selected,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: selected.isEmpty ? null : (options.contains(selected) ? selected : null),
      dropdownColor: isDarkMode ? darkCard : Colors.white,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: firAmber,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: options.isEmpty ? null : onChanged,
    );
  }

  Widget _buildPrimaryBtn(String text, VoidCallback onTap) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [firAmber, Color(0xFFD97706)],
        ),
        boxShadow: [
          BoxShadow(
            color: firAmber.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: firAmber),
      ),
    );
  }

  Widget _buildStoreCard(
      HomeStoreModel store,
      Color cardColor,
      Color textColor,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: firAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              store.name.isNotEmpty ? store.name[0].toUpperCase() : 'M',
              style: const TextStyle(
                color: firAmber,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ),
        title: Text(
          store.name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${store.city} • ${store.district}',
          style: const TextStyle(color: mutedGray, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: mutedGray,
          size: 16,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailPage(storeId: store.id!),
          ),
        ),
      ),
    );
  }

  void _showGuestRestriction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Misafir kullanıcılar $action işlemini yapamaz.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _yearMinController.dispose();
    _yearMaxController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _kmMinController.dispose();
    _kmMaxController.dispose();
    super.dispose();
  }
}