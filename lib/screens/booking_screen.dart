import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hotel_models.dart';
import '../state/hotel_app_state.dart';
import '../utils/formatters.dart';
import '../widgets/hotel_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 2;
  final Set<String> _selectedExtraIds = {};

  static const List<_BookingExtra> _extras = [
    _BookingExtra(
      id: 'breakfast',
      label: 'Kahvaltı',
      caption: 'Kişi başı / gece',
      price: 450,
      perNight: true,
      icon: Icons.restaurant_rounded,
    ),
    _BookingExtra(
      id: 'transfer',
      label: 'Transfer',
      caption: 'Tek yön',
      price: 900,
      perNight: false,
      icon: Icons.airport_shuttle_rounded,
    ),
    _BookingExtra(
      id: 'late_checkout',
      label: 'Geç çıkış',
      caption: '14:00 çıkış',
      price: 600,
      perNight: false,
      icon: Icons.schedule_rounded,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateUtils.dateOnly(DateTime.now());
    final initialStart = _checkInDate != null && !_checkInDate!.isBefore(now)
        ? _checkInDate!
        : now.add(const Duration(days: 7));
    final initialEnd =
        _checkOutDate != null && _checkOutDate!.isAfter(initialStart)
            ? _checkOutDate!
            : initialStart.add(const Duration(days: 2));

    final range = await showDateRangePicker(
      context: context,
      helpText: 'Tarih aralığı',
      cancelText: 'İptal',
      confirmText: 'Uygula',
      saveText: 'Uygula',
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (range == null) {
      return;
    }

    setState(() {
      _checkInDate = range.start;
      _checkOutDate = range.end;
    });
  }

  Future<void> _submit(HotelAppState state) async {
    final room = state.selectedRoom;
    if (room == null) {
      return;
    }

    final boundedGuests =
        _guestCount > room.maxGuests ? room.maxGuests : _guestCount;
    final formIsValid = _formKey.currentState!.validate();
    final hasValidDates = _checkInDate != null &&
        _checkOutDate != null &&
        _checkOutDate!.isAfter(_checkInDate!);

    if (!formIsValid || !hasValidDates) {
      final message = !formIsValid
          ? 'Eksik alanları doldurun.'
          : 'Çıkış tarihi giriş tarihinden sonra olmalı.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final extras = _selectedExtras;
    await state.saveReservation(
      guestName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      checkIn: _checkInDate!,
      checkOut: _checkOutDate!,
      guests: boundedGuests,
      specialRequest: _noteController.text.trim(),
      extras: extras.map((item) => item.label).toList(),
      extrasTotal: _extrasTotal(boundedGuests, _nightCount),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rezervasyon oluşturuldu.')),
    );

    setState(() {
      _nameController.clear();
      _emailController.clear();
      _noteController.clear();
      _checkInDate = null;
      _checkOutDate = null;
      _guestCount = 2;
      _selectedExtraIds.clear();
    });
  }

  int get _nightCount {
    if (_checkInDate == null || _checkOutDate == null) {
      return 1;
    }

    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    return nights > 0 ? nights : 1;
  }

  List<_BookingExtra> get _selectedExtras => _extras
      .where((item) => _selectedExtraIds.contains(item.id))
      .toList(growable: false);

  int _extrasTotal(int guests, int nights) {
    return _selectedExtras.fold(
      0,
      (sum, item) => sum + _extraCost(item, guests, nights),
    );
  }

  int _extraCost(_BookingExtra item, int guests, int nights) {
    final multiplier = item.perNight ? nights : 1;
    final guestMultiplier = item.id == 'breakfast' ? guests : 1;
    return item.price * multiplier * guestMultiplier;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width >= 1080 ? 24.0 : 16.0;

    return Consumer<HotelAppState>(
      builder: (context, state, _) {
        final hotel = state.selectedHotel;
        final room = state.selectedRoom;

        if (hotel == null || room == null) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _EmptyBookingState(padding: padding),
            ),
          );
        }

        final rooms = state.roomsForSelectedHotel;
        final guestCount =
            _guestCount > room.maxGuests ? room.maxGuests : _guestCount;
        final extrasTotal = _extrasTotal(guestCount, _nightCount);
        final roomTotal = room.nightlyRate * _nightCount;
        final grandTotal = roomTotal + extrasTotal;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 18, padding, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhotoHero(
                    imagePath: hotel.imagePath,
                    eyebrow: '${hotel.city} • ${hotel.area}',
                    title: hotel.name,
                    subtitle:
                        '${hotel.rating.toStringAsFixed(1)} puan • ${hotel.reviewCount}+ yorum',
                    height: 180,
                  ),
                  const SizedBox(height: 12),
                  SectionHeader(
                    eyebrow: 'Varyantlar',
                    title: 'Odalar',
                    subtitle: '${rooms.length} seçenek',
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 10.0;
                      final columns = constraints.maxWidth >= 300 ? 3 : 2;
                      final totalGap = gap * (columns - 1);
                      final cardWidth =
                          (constraints.maxWidth - totalGap) / columns;
                      final cardHeight =
                          constraints.maxWidth >= 920 ? 180.0 : 172.0;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: rooms
                            .map(
                              (item) => SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: _BookingRoomCard(
                                  room: item,
                                  selected: item.id == room.id,
                                  onTap: () {
                                    state.selectRoom(item.id);
                                    if (_guestCount > item.maxGuests) {
                                      setState(() {
                                        _guestCount = item.maxGuests;
                                      });
                                    }
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;
                      final form = SoftPanel(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Rezervasyon',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      formatCurrency(grandTotal),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              LayoutBuilder(
                                builder: (context, localConstraints) {
                                  final gap = 8.0;
                                  final statWidth = localConstraints.maxWidth >=
                                          560
                                      ? (localConstraints.maxWidth -
                                              (gap * 2)) /
                                          3
                                      : (localConstraints.maxWidth - gap) / 2;

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      SizedBox(
                                        width: statWidth,
                                        child: _BookingMetricCard(
                                          label: 'Oda',
                                          value: room.name,
                                          icon: Icons.bed_rounded,
                                        ),
                                      ),
                                      SizedBox(
                                        width: statWidth,
                                        child: _BookingMetricCard(
                                          label: 'Gece',
                                          value: '$_nightCount',
                                          icon: Icons.nights_stay_rounded,
                                        ),
                                      ),
                                      SizedBox(
                                        width: statWidth,
                                        child: _BookingMetricCard(
                                          label: 'Misafir',
                                          value: '$guestCount',
                                          icon: Icons.group_rounded,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              const _BookingSectionLabel('Misafir bilgileri'),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, localConstraints) {
                                  final wideFields =
                                      localConstraints.maxWidth >= 620;

                                  final nameField = TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Ad soyad',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Zorunlu alan';
                                      }
                                      return null;
                                    },
                                  );

                                  final emailField = TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'E-posta',
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty ||
                                          !email.contains('@')) {
                                        return 'Geçerli e-posta girin';
                                      }
                                      return null;
                                    },
                                  );

                                  if (!wideFields) {
                                    return Column(
                                      children: [
                                        nameField,
                                        const SizedBox(height: 12),
                                        emailField,
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(child: nameField),
                                      const SizedBox(width: 12),
                                      Expanded(child: emailField),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              const _BookingSectionLabel('Tarih ve konaklama'),
                              const SizedBox(height: 10),
                              _DateRangeCard(
                                start: _checkInDate,
                                end: _checkOutDate,
                                nightCount: _nightCount,
                                onTap: () => _pickDateRange(context),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Misafir',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const Spacer(),
                                    IconButton.filledTonal(
                                      onPressed: guestCount > 1
                                          ? () {
                                              setState(() {
                                                _guestCount = guestCount - 1;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.remove_rounded),
                                    ),
                                    SizedBox(
                                      width: 42,
                                      child: Text(
                                        '$guestCount',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    IconButton.filledTonal(
                                      onPressed: guestCount < room.maxGuests
                                          ? () {
                                              setState(() {
                                                _guestCount = guestCount + 1;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.add_rounded),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              const _BookingSectionLabel('Ek hizmetler'),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, localConstraints) {
                                  const gap = 8.0;
                                  final columns =
                                      localConstraints.maxWidth >= 720 ? 3 : 1;
                                  final itemWidth = columns == 1
                                      ? localConstraints.maxWidth
                                      : (localConstraints.maxWidth -
                                              ((columns - 1) * gap)) /
                                          columns;

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _extras
                                        .map(
                                          (item) => SizedBox(
                                            width: itemWidth,
                                            child: _ExtraOptionCard(
                                              item: item,
                                              selected: _selectedExtraIds
                                                  .contains(item.id),
                                              totalCost: _extraCost(
                                                item,
                                                guestCount,
                                                _nightCount,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (_selectedExtraIds
                                                      .contains(item.id)) {
                                                    _selectedExtraIds
                                                        .remove(item.id);
                                                  } else {
                                                    _selectedExtraIds
                                                        .add(item.id);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              const _BookingSectionLabel('Not'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _noteController,
                                minLines: 3,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Not',
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _submit(state),
                                  child: const Text('Rezervasyonu tamamla'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      final summary = SoftPanel(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BookingSummaryHero(
                              hotelName: hotel.name,
                              roomName: room.name,
                              imagePath: room.imagePath,
                              dateLabel:
                                  _checkInDate != null && _checkOutDate != null
                                      ? formatDateRange(
                                          _checkInDate!,
                                          _checkOutDate!,
                                        )
                                      : 'Tarih seçilmedi',
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Genel toplam',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatCurrency(grandTotal),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SummaryInfoTile(
                              icon: Icons.calendar_today_rounded,
                              label: 'Tarih',
                              value:
                                  _checkInDate != null && _checkOutDate != null
                                      ? formatDateRange(
                                          _checkInDate!,
                                          _checkOutDate!,
                                        )
                                      : '-',
                            ),
                            const SizedBox(height: 8),
                            _SummaryInfoTile(
                              icon: Icons.group_rounded,
                              label: 'Misafir',
                              value: '$guestCount',
                            ),
                            const SizedBox(height: 8),
                            _SummaryInfoTile(
                              icon: Icons.nights_stay_rounded,
                              label: 'Gece',
                              value: '$_nightCount',
                            ),
                            const SizedBox(height: 14),
                            _SummaryLine(
                              label: 'Oda',
                              value: '${formatCurrency(room.nightlyRate)}/gece',
                            ),
                            _SummaryLine(
                              label: 'Oda toplamı',
                              value: formatCurrency(roomTotal),
                            ),
                            _SummaryLine(
                              label: 'Ek hizmet',
                              value: formatCurrency(extrasTotal),
                            ),
                            _SummaryLine(
                              label: 'Genel toplam',
                              value: formatCurrency(grandTotal),
                            ),
                            if (_selectedExtras.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const _BookingSectionLabel('Ek hizmetler'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _selectedExtras
                                    .map(
                                      (item) => FeaturePill(
                                        label:
                                            '${item.label} ${formatCurrency(_extraCost(item, guestCount, _nightCount))}',
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 12),
                            const _BookingSectionLabel('Oda özellikleri'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: room.perks
                                  .take(2)
                                  .map((perk) => FeaturePill(label: perk))
                                  .toList(),
                            ),
                          ],
                        ),
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: form),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: summary),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          form,
                          const SizedBox(height: 16),
                          summary,
                        ],
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

class _EmptyBookingState extends StatelessWidget {
  const _EmptyBookingState({
    required this.padding,
  });

  final double padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, 24, padding, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SoftPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.hotel_class_rounded,
                  size: 44,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 14),
                Text(
                  'Rezervasyon',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Seçili tesis yok',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingRoomCard extends StatelessWidget {
  const _BookingRoomCard({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  final RoomOffer room;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SoftPanel(
        backgroundColor:
            selected ? room.accent.withValues(alpha: 0.07) : Colors.white,
        borderColor: selected ? room.accent.withValues(alpha: 0.24) : null,
        padding: const EdgeInsets.all(8),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(room.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 2),
            Text(
              room.sizeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              '${room.maxGuests} misafir',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatCurrency(room.nightlyRate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: Text(selected ? 'Seçili' : 'Seç'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingMetricCard extends StatelessWidget {
  const _BookingMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.start,
    required this.end,
    required this.nightCount,
    required this.onTap,
  });

  final DateTime? start;
  final DateTime? end;
  final int nightCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRange = start != null && end != null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konaklama tarihi',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasRange
                        ? formatDateRange(start!, end!)
                        : 'Tarih aralığı seçin',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            if (hasRange) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$nightCount gece',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExtraOptionCard extends StatelessWidget {
  const _ExtraOptionCard({
    required this.item,
    required this.selected,
    required this.totalCost,
    required this.onTap,
  });

  final _BookingExtra item;
  final bool selected;
  final int totalCost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.secondary.withValues(alpha: 0.22)
                : theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(item.caption, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    formatCurrency(totalCost),
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary.withValues(alpha: 0.36),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSectionLabel extends StatelessWidget {
  const _BookingSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _BookingSummaryHero extends StatelessWidget {
  const _BookingSummaryHero({
    required this.hotelName,
    required this.roomName,
    required this.imagePath,
    required this.dateLabel,
  });

  final String hotelName;
  final String roomName;
  final String imagePath;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  dateLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryInfoTile extends StatelessWidget {
  const _SummaryInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingExtra {
  const _BookingExtra({
    required this.id,
    required this.label,
    required this.caption,
    required this.price,
    required this.perNight,
    required this.icon,
  });

  final String id;
  final String label;
  final String caption;
  final int price;
  final bool perNight;
  final IconData icon;
}
