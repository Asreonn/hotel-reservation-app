import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/hotel_app_state.dart';
import 'booking_screen.dart';
import 'hotels_screen.dart';
import 'reservations_screen.dart';

class HotelShell extends StatefulWidget {
  const HotelShell({super.key});

  @override
  State<HotelShell> createState() => _HotelShellState();
}

class _HotelShellState extends State<HotelShell> {
  int _currentIndex = 0;

  final List<_ShellItem> _items = const [
    _ShellItem('Oteller', Icons.apartment_rounded),
    _ShellItem('Rezervasyon', Icons.bed_rounded),
    _ShellItem('Rezervasyonlar', Icons.event_note_rounded),
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1080;
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _buildScreen(_currentIndex),
      ),
    );

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              _Sidebar(
                items: _items,
                currentIndex: _currentIndex,
                onNavigate: _navigateTo,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateTo,
        destinations: _items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HotelsScreen(onNavigate: _navigateTo);
      case 1:
        return const BookingScreen();
      case 2:
        return const ReservationsScreen();
      default:
        return HotelsScreen(onNavigate: _navigateTo);
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onNavigate,
  });

  final List<_ShellItem> items;
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 264,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Consumer<HotelAppState>(
        builder: (context, state, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'StayBook',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Otel rezervasyonu',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Kompakt ve ticari rezervasyon akışı',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedHotel?.name ?? 'Otel seçilmedi',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.selectedHotel == null
                          ? 'Oteller menüsünden bir tesis seçin'
                          : '${state.selectedHotel!.area}, ${state.selectedHotel!.city}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.event_note_rounded,
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${state.upcomingReservations.length} yaklaşan rezervasyon',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = currentIndex == index;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onNavigate(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.secondary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? theme.colorScheme.secondary
                                    .withValues(alpha: 0.18)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.62),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary
                                        .withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShellItem {
  const _ShellItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
