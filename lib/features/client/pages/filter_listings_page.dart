import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/auth/models/home_store_model.dart';
import 'package:otoport_mobile/features/auth/models/listing_card_model.dart';
import 'package:otoport_mobile/features/auth/services/filter_listing_store_service.dart';
import 'package:otoport_mobile/features/auth/services/home_service.dart';
import 'package:otoport_mobile/features/client/pages/store_detail_page.dart';
import 'package:otoport_mobile/core/services/image_service.dart';

import 'listing_detail_page.dart';

class FilterListingsPage extends StatefulWidget {
  final String q;
  final String brand;
  final String model;
  final String variant;
  final String engine;
  final String pack;
  final String bodyType;
  final int? yearMin;
  final int? yearMax;
  final double? priceMin;
  final double? priceMax;
  final int? kmMin;
  final int? kmMax;

  const FilterListingsPage({
    super.key,
    this.q = '',
    this.brand = '',
    this.model = '',
    this.variant = '',
    this.engine = '',
    this.pack = '',
    this.bodyType = '',
    this.yearMin,
    this.yearMax,
    this.priceMin,
    this.priceMax,
    this.kmMin,
    this.kmMax,
  });

  @override
  State<FilterListingsPage> createState() => _FilterListingsPageState();
}

class _FilterListingsPageState extends State<FilterListingsPage> {
  final FilterListingStoreService _filterService = FilterListingStoreService();
  final HomeService _homeService = HomeService();

  static const Color firAmber = Color(0xFFFFB020);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color mutedGray = Color(0xFF9AA3B2);

  bool isDarkMode = true;
  bool isLoading = true;
  String? errorMessage;

  String priceSort = '';
  String yearSort = '';
  String kmSort = '';

  List<ListingCardModel> filteredListings = [];
  List<int> orderedStoreIds = [];
  Map<int, List<ListingCardModel>> groupedListings = {};
  Map<int, HomeStoreModel> storeIndex = {};

  static const Set<String> _binekTypes = {
    'SEDAN',
    'HATCHBACK',
    'COUPE',
    'STATION_WAGON',
    'CABRIO',
  };

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  String _norm(String? value) {
    return (value ?? '').trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeBodyType(String? value) {
    var s = (value ?? '').trim().toUpperCase();
    if (s.isEmpty) return '';
    if (s == 'BINEK' || s.contains('BINEK')) return 'BINEK';
    final k = s.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (k == 'HB' || k.contains('HATCHBACK')) return 'HATCHBACK';
    if (k.contains('SEDAN') || k == 'SD') return 'SEDAN';
    if (k.contains('SUV') || k.contains('CROSSOVER')) return 'SUV';
    if (k.contains('COUPE')) return 'COUPE';
    if (k.contains('VAN') || k.contains('PANELVAN')) return 'VAN';
    return s;
  }

  bool _engineMatches(String? listingEngine, String selectedEngine) {
    final e = _norm(listingEngine);
    final s = _norm(selectedEngine);
    if (s.isEmpty) return true;
    if (e.isEmpty) return false;
    if (e == s) return true;

    final parts = s.split(' ').where((x) => x.trim().isNotEmpty).toList();
    for (final p in parts) {
      if (!e.contains(p)) return false;
    }
    return true;
  }

  bool _variantMatches(ListingCardModel l, String selectedVariant) {
    final selected = selectedVariant.trim().toLowerCase();
    if (selected.isEmpty) return true;

    final title = l.title.toLowerCase();
    return title.contains(selected);
  }

  bool _hasActiveSorts() {
    return priceSort.isNotEmpty || yearSort.isNotEmpty || kmSort.isNotEmpty;
  }

  bool _hasSidebarVehicleFilters() {
    return widget.brand.trim().isNotEmpty ||
        widget.model.trim().isNotEmpty ||
        widget.variant.trim().isNotEmpty ||
        widget.engine.trim().isNotEmpty ||
        widget.pack.trim().isNotEmpty ||
        widget.bodyType.trim().isNotEmpty ||
        widget.yearMin != null ||
        widget.yearMax != null ||
        widget.priceMin != null ||
        widget.priceMax != null ||
        widget.kmMin != null ||
        widget.kmMax != null;
  }

  bool _shouldUseFlatListingView() {
    return _hasActiveSorts() && !_hasSidebarVehicleFilters();
  }

  List<ListingCardModel> _applyClientFilter(List<ListingCardModel> listings) {
    var out = List<ListingCardModel>.from(listings);

    final q = widget.q.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((l) {
        return (l.storeName ?? '').toLowerCase().contains(q) ||
            l.title.toLowerCase().contains(q) ||
            (l.brand ?? '').toLowerCase().contains(q) ||
            (l.model ?? '').toLowerCase().contains(q) ||
            (l.engine ?? '').toLowerCase().contains(q);
      }).toList();
    }

    if (widget.brand.trim().isNotEmpty) {
      final b = widget.brand.trim().toLowerCase();
      out = out.where((l) => (l.brand ?? '').trim().toLowerCase() == b).toList();
    }

    if (widget.model.trim().isNotEmpty) {
      final m = widget.model.trim().toLowerCase();
      out = out.where((l) => (l.model ?? '').trim().toLowerCase() == m).toList();
    }

    if (widget.variant.trim().isNotEmpty) {
      out = out.where((l) => _variantMatches(l, widget.variant)).toList();
    }

    if (widget.yearMin != null) {
      out = out.where((l) => l.year != null && l.year! >= widget.yearMin!).toList();
    }

    if (widget.yearMax != null) {
      out = out.where((l) => l.year != null && l.year! <= widget.yearMax!).toList();
    }

    if (widget.priceMin != null) {
      out = out.where((l) => (l.price ?? 0) >= widget.priceMin!).toList();
    }

    if (widget.priceMax != null) {
      out = out.where((l) => (l.price ?? 0) <= widget.priceMax!).toList();
    }

    if (widget.kmMin != null) {
      out = out
          .where((l) => l.kilometer != null && l.kilometer! >= widget.kmMin!)
          .toList();
    }

    if (widget.kmMax != null) {
      out = out
          .where((l) => l.kilometer != null && l.kilometer! <= widget.kmMax!)
          .toList();
    }

    if (widget.bodyType.trim().isNotEmpty) {
      final bt = _normalizeBodyType(widget.bodyType);
      out = out.where((l) {
        if (bt == 'BINEK') {
          return _binekTypes.contains(_normalizeBodyType(l.bodyType));
        }
        return _normalizeBodyType(l.bodyType) == bt;
      }).toList();
    }

    if (widget.engine.trim().isNotEmpty) {
      out = out.where((l) => _engineMatches(l.engine, widget.engine)).toList();
    }

    if (widget.pack.trim().isNotEmpty) {
      final p = widget.pack.trim().toLowerCase();
      out = out.where((l) => l.title.toLowerCase().contains(p)).toList();
    }

    return out;
  }

  Map<int, int> _buildRankMap(
      List<ListingCardModel> items,
      int Function(ListingCardModel a, ListingCardModel b) compare,
      ) {
    final copy = List<ListingCardModel>.from(items)..sort(compare);
    final map = <int, int>{};
    for (int i = 0; i < copy.length; i++) {
      final id = copy[i].id;
      if (id != null) map[id] = i;
    }
    return map;
  }

  List<ListingCardModel> _sortListingsClient(List<ListingCardModel> items) {
    final out = List<ListingCardModel>.from(items);

    if (!_hasActiveSorts()) return out;

    int compareNum(num? a, num? b, String dir) {
      final av = a ?? 999999999;
      final bv = b ?? 999999999;
      return dir == 'DESC' ? bv.compareTo(av) : av.compareTo(bv);
    }

    final priceRank = priceSort.isNotEmpty
        ? _buildRankMap(out, (a, b) => compareNum(a.price, b.price, priceSort))
        : <int, int>{};

    final yearRank = yearSort.isNotEmpty
        ? _buildRankMap(out, (a, b) => compareNum(a.year, b.year, yearSort))
        : <int, int>{};

    final kmRank = kmSort.isNotEmpty
        ? _buildRankMap(
      out,
          (a, b) => compareNum(a.kilometer, b.kilometer, kmSort),
    )
        : <int, int>{};

    int scoreOf(ListingCardModel item) {
      final id = item.id ?? -1;
      return (priceRank[id] ?? 0) + (yearRank[id] ?? 0) + (kmRank[id] ?? 0);
    }

    out.sort((a, b) {
      final sa = scoreOf(a);
      final sb = scoreOf(b);
      if (sa != sb) return sa.compareTo(sb);
      return (a.id ?? 999999999).compareTo(b.id ?? 999999999);
    });

    return out;
  }

  Future<void> _loadPage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final flatMode = _shouldUseFlatListingView();

      final listings = await _filterService.getAllListings(
        all: true,
        priceSort: flatMode && priceSort.isNotEmpty ? priceSort : null,
        yearSort: flatMode && yearSort.isNotEmpty ? yearSort : null,
        kmSort: flatMode && kmSort.isNotEmpty ? kmSort : null,
      );

      final stores = await _homeService.getStores(limit: 200);

      var filtered = _applyClientFilter(listings);

      if (!flatMode) {
        filtered = _sortListingsClient(filtered);
      }

      final grouped = <int, List<ListingCardModel>>{};
      for (final item in filtered) {
        final sid = item.storeId;
        if (sid == null || sid <= 0) continue;
        grouped.putIfAbsent(sid, () => []);
        grouped[sid]!.add(item);
      }

      final storeIds = grouped.keys.toList();
      List<int> rankedIds = storeIds;

      if (storeIds.length > 1) {
        try {
          rankedIds = await _filterService.rankStores(
            storeIds: storeIds,
            seedKey: [
              widget.q,
              widget.brand,
              widget.model,
              widget.variant,
              widget.bodyType,
              widget.engine,
              widget.pack,
              widget.yearMin?.toString() ?? '',
              widget.yearMax?.toString() ?? '',
              widget.priceMin?.toString() ?? '',
              widget.priceMax?.toString() ?? '',
              widget.kmMin?.toString() ?? '',
              widget.kmMax?.toString() ?? '',
              priceSort,
              yearSort,
              kmSort,
            ].join('|'),
          );
        } catch (_) {}
      }

      final index = <int, HomeStoreModel>{};
      for (final s in stores) {
        if (s.id != null) index[s.id!] = s;
      }

      if (!mounted) return;

      setState(() {
        filteredListings = filtered;
        groupedListings = grouped;
        orderedStoreIds =
            rankedIds.where((id) => grouped.containsKey(id)).toList();
        storeIndex = index;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Sonuçlar yüklenemedi: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
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

  Widget _buildAmberDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    final cardColor = isDarkMode ? darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: firAmber.withOpacity(0.45)),
          gradient: LinearGradient(
            colors: [
              firAmber.withOpacity(0.16),
              firAmber.withOpacity(0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: firAmber.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: firAmber,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: cardColor,
                iconEnabledColor: firAmber,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Row(
      children: [
        _buildAmberDropdown(
          label: 'Fiyat',
          value: priceSort,
          items: const [
            DropdownMenuItem(value: '', child: Text('Önerilen')),
            DropdownMenuItem(value: 'DESC', child: Text('En yüksek')),
            DropdownMenuItem(value: 'ASC', child: Text('En düşük')),
          ],
          onChanged: (v) {
            setState(() => priceSort = v ?? '');
            _loadPage();
          },
        ),
        const SizedBox(width: 10),
        _buildAmberDropdown(
          label: 'Model',
          value: yearSort,
          items: const [
            DropdownMenuItem(value: '', child: Text('Önerilen')),
            DropdownMenuItem(value: 'DESC', child: Text('En yüksek')),
            DropdownMenuItem(value: 'ASC', child: Text('En düşük')),
          ],
          onChanged: (v) {
            setState(() => yearSort = v ?? '');
            _loadPage();
          },
        ),
        const SizedBox(width: 10),
        _buildAmberDropdown(
          label: 'KM',
          value: kmSort,
          items: const [
            DropdownMenuItem(value: '', child: Text('Önerilen')),
            DropdownMenuItem(value: 'ASC', child: Text('En düşük')),
            DropdownMenuItem(value: 'DESC', child: Text('En yüksek')),
          ],
          onChanged: (v) {
            setState(() => kmSort = v ?? '');
            _loadPage();
          },
        ),
      ],
    );
  }

  Widget _buildListingCard(
      ListingCardModel item,
      Color cardColor,
      Color textColor,
      ) {
    final imageUrl = _normalizeImageUrl(item.coverImageUrl);

    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black12,
        ),
      ),
      child: InkWell(
        onTap: item.id == null
            ? null
            : () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(listingId: item.id!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: mutedGray,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price ?? '—'} ${item.currency ?? 'TRY'}',
                    style: const TextStyle(
                      color: firAmber,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.year ?? '—'} • ${item.kilometer != null ? '${item.kilometer} km' : '—'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: mutedGray, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.city ?? '—',
                    maxLines: 1,
                    style: const TextStyle(color: mutedGray, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatListingCard(
      ListingCardModel item,
      Color cardColor,
      Color textColor,
      ) {
    final imageUrl = _normalizeImageUrl(item.coverImageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.id == null
            ? null
            : () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(listingId: item.id!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: mutedGray,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mağaza Adı',
                    style: TextStyle(
                      color: mutedGray.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.storeName ?? 'Mağaza',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.price ?? '—'} ${item.currency ?? 'TRY'}',
                    style: const TextStyle(
                      color: firAmber,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _specChip('${item.year ?? '—'}'),
                      _specChip(
                        item.kilometer != null ? '${item.kilometer} km' : '—',
                      ),
                      _specChip(item.city ?? '—'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: firAmber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: firAmber,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStoreGroup(int storeId, Color cardColor, Color textColor) {
    final listings = groupedListings[storeId] ?? [];
    final store = storeIndex[storeId];
    final storeName = store?.name ?? listings.first.storeName ?? 'Mağaza';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoreDetailPage(storeId: storeId),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: firAmber.withOpacity(0.1),
                  radius: 22,
                  child: Text(
                    storeName.isNotEmpty ? storeName[0] : 'M',
                    style: const TextStyle(
                      color: firAmber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${store?.city ?? '—'} / ${store?.district ?? '—'}',
                        style: const TextStyle(
                          color: mutedGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: firAmber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${listings.length} İlan',
                    style: const TextStyle(
                      color: firAmber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              itemBuilder: (context, index) => _buildListingCard(
                listings[index],
                isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.02),
                textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(Color cardColor, Color textColor) {
    final widgets = <Widget>[
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Arama Sonuçları',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Text(
              _shouldUseFlatListingView()
                  ? '${filteredListings.length} İlan'
                  : '${groupedListings.length} Mağaza • ${filteredListings.length} İlan',
              style: const TextStyle(
                color: firAmber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _buildSortBar(),
      const SizedBox(height: 20),
    ];

    if (errorMessage != null) {
      widgets.add(
        Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    if (!isLoading && filteredListings.isEmpty) {
      widgets.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Kriterlere uygun sonuç bulunamadı.',
              style: TextStyle(color: mutedGray),
            ),
          ),
        ),
      );
      return widgets;
    }

    if (_shouldUseFlatListingView()) {
      widgets.addAll(
        filteredListings.map(
              (item) => _buildFlatListingCard(item, cardColor, textColor),
        ),
      );
    } else {
      widgets.addAll(
        orderedStoreIds.map((id) => _buildStoreGroup(id, cardColor, textColor)),
      );
    }

    return widgets;
  }
  String _normalizeImageUrl(String? path) {
    return ImageService.withFallback(path);
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
          const SizedBox(width: 12),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: firAmber),
      )
          : RefreshIndicator(
        onRefresh: _loadPage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _buildBody(cardColor, textColor),
        ),
      ),
    );
  }
}
