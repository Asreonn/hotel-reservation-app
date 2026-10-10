import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hotel_models.dart';
import '../state/hotel_app_state.dart';
import '../utils/formatters.dart';
import '../widgets/hotel_widgets.dart';

enum ReservationFilter { upcoming, past }

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  ReservationFilter _filter = ReservationFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width >= 1080 ? 24.0 : 16.0;

    return Consumer<HotelAppState>(
      builder: (context, state, _) {
        final items = _filter == ReservationFilter.upcoming
            ? state.upcomingReservations
            : state.pastReservations;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 18, padding, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    eyebrow: 'Rezervasyonlar',
                    title: 'Yaklaşan ve geçmiş',
                    subtitle: '${state.upcomingReservations.length} yaklaşan • '
                        '${state.pastReservations.length} geçmiş',
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<ReservationFilter>(
                    selected: {_filter},
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ReservationFilter.upcoming,
                        label: Text('Yaklaşan'),
                      ),
                      ButtonSegment(
                        value: ReservationFilter.past,
                        label: Text('Geçmiş'),
                      ),
                    ],
                    onSelectionChanged: (selection) {
                      setState(() {
                        _filter = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const SoftPanel(
                      child: Text('Bu listede rezervasyon yok.'),
                    )
                  else
                    Column(
                      children: items
                          .map(
                            (reservation) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ReservationCard(reservation: reservation),
                            ),
                          )
                          .toList(),
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

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
  });

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final isPast = reservation.checkOut.isBefore(DateTime.now());
    return SoftPanel(
      backgroundColor:
          isPast ? const Color(0xFFF8F3EE) : const Color(0xFFF6FAFB),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 104,
            decoration: BoxDecoration(
              color: isPast
                  ? const Color(0xFF9E7A5E)
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reservation.hotelName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FeaturePill(label: isPast ? 'Geçmiş' : 'Yaklaşan'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(reservation.roomName),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FeaturePill(
                      label: formatDateRange(
                        reservation.checkIn,
                        reservation.checkOut,
                      ),
                    ),
                    FeaturePill(label: '${reservation.guests} misafir'),
                    FeaturePill(label: '${reservation.nights} gece'),
                    FeaturePill(label: formatCurrency(reservation.totalPrice)),
                    ...reservation.extras
                        .map((item) => FeaturePill(label: item)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  reservation.guestName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(reservation.email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
