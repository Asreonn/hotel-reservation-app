import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hotel_models.dart';
import '../state/hotel_app_state.dart';
import '../widgets/hotel_widgets.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({
    super.key,
    required this.onNavigate,
  });

  final ValueChanged<int> onNavigate;

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final _searchController = TextEditingController();
  String? _selectedArea;
  double? _minimumRating;
  final Set<String> _selectedFeatures = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HotelListing> _visibleHotels(HotelAppState state) {
    final query = _searchController.text.trim().toLowerCase();

    return state.hotels.where((hotel) {
      final matchesArea = _selectedArea == null || hotel.area == _selectedArea;
      final matchesRating =
          _minimumRating == null || hotel.rating >= _minimumRating!;
      final matchesFeatures = _selectedFeatures.every(hotel.tags.contains);

      if (!matchesArea || !matchesRating || !matchesFeatures) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchText = [
        hotel.name,
        hotel.city,
        hotel.area,
        hotel.description,
        ...hotel.tags,
      ].join(' ').toLowerCase();

      return searchText.contains(query);
    }).toList(growable: false);
  }

  int get _activeFilterCount {
    var count = _selectedFeatures.length;
    if (_selectedArea != null) {
      count += 1;
    }
    if (_minimumRating != null) {
      count += 1;
    }
    return count;
  }

  Future<void> _openFilterSheet(HotelAppState state) async {
    final areas = state.hotels.map((hotel) => hotel.area).toSet().toList()
      ..sort();
    final features = state.hotels.expand((hotel) => hotel.tags).toSet().toList()
      ..sort();

    final result = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var tempArea = _selectedArea;
        var tempRating = _minimumRating;
        final tempFeatures = Set<String>.from(_selectedFeatures);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Filtreler',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  tempArea = null;
                                  tempRating = null;
                                  tempFeatures.clear();
                                });
                              },
                              child: const Text('Temizle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Semt',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: areas
                              .map(
                                (area) => ChoiceChip(
                                  label: Text(area),
                                  selected: tempArea == area,
                                  onSelected: (_) {
                                    setModalState(() {
                                      tempArea = tempArea == area ? null : area;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Puan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [4.5, 4.7, 4.8]
                              .map(
                                (rating) => ChoiceChip(
                                  label: Text('${rating.toStringAsFixed(1)}+'),
                                  selected: tempRating == rating,
                                  onSelected: (_) {
                                    setModalState(() {
                                      tempRating =
                                          tempRating == rating ? null : rating;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Özellikler',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: features
                              .map(
                                (feature) => FilterChip(
                                  label: Text(feature),
                                  selected: tempFeatures.contains(feature),
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        tempFeatures.add(feature);
                                      } else {
                                        tempFeatures.remove(feature);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                _FilterSelection(
                                  area: tempArea,
                                  minimumRating: tempRating,
                                  features: tempFeatures,
                                ),
                              );
                            },
                            child: const Text('Uygula'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedArea = result.area;
      _minimumRating = result.minimumRating;
      _selectedFeatures
        ..clear()
        ..addAll(result.features);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width >= 1080 ? 24.0 : 16.0;

    return Consumer<HotelAppState>(
      builder: (context, state, _) {
        final hotels = _visibleHotels(state);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 16, padding, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Oteller',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      _FilterCountPill(
                        label: '${hotels.length} ilan',
                        icon: Icons.grid_view_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SoftPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Arama',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () => _openFilterSheet(state),
                              icon: const Icon(
                                Icons.tune_rounded,
                                size: 18,
                              ),
                              label: Text(
                                _activeFilterCount == 0
                                    ? 'Filtreler'
                                    : 'Filtreler ($_activeFilterCount)',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Otel veya bölge ara',
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${hotels.length} ilan',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (hotels.isEmpty)
                    const SoftPanel(
                      child: Text('Aramanıza uygun otel bulunamadı.'),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 12.0;
                        final columns = constraints.maxWidth >= 360 ? 2 : 1;
                        final totalGap = gap * (columns - 1);
                        final cardWidth =
                            (constraints.maxWidth - totalGap) / columns;
                        final cardHeight =
                            constraints.maxWidth >= 920 ? 360.0 : 336.0;

                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: hotels
                              .map(
                                (hotel) => SizedBox(
                                  width: cardWidth,
                                  height: cardHeight,
                                  child: _HotelCard(
                                    hotel: hotel,
                                    selected: state.selectedHotelId == hotel.id,
                                    onTap: () {
                                      state.selectHotel(hotel.id);
                                      widget.onNavigate(1);
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.selected,
    required this.onTap,
  });

  final HotelListing hotel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SoftPanel(
        backgroundColor:
            selected ? hotel.accent.withValues(alpha: 0.07) : Colors.white,
        borderColor: selected ? hotel.accent.withValues(alpha: 0.22) : null,
        padding: const EdgeInsets.all(8),
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(hotel.imagePath, fit: BoxFit.cover),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.52),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${hotel.area}, ${hotel.city}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: hotel.accent,
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hotel.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              hotel.tags.take(2).join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  hotel.rating.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${hotel.reviewCount}+ yorum',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onTap,
                child: const Text('Detay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterCountPill extends StatelessWidget {
  const _FilterCountPill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _FilterSelection {
  const _FilterSelection({
    required this.area,
    required this.minimumRating,
    required this.features,
  });

  final String? area;
  final double? minimumRating;
  final Set<String> features;
}
