import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_content.dart';
import '../models/hotel_models.dart';

class HotelAppState extends ChangeNotifier {
  static const _storageKey = 'staybook_reservations_v3';
  static const _legacyStorageKey = 'aurea_stay_reservations_v2';

  final List<HotelListing> hotels = List.unmodifiable(demoHotels);
  final List<RoomOffer> rooms = List.unmodifiable(demoRooms);

  String? _selectedHotelId;
  String? _selectedRoomId;
  List<Reservation> _reservations = [];

  String? get selectedHotelId => _selectedHotelId;

  HotelListing? get selectedHotel {
    final id = _selectedHotelId;
    if (id == null) {
      return null;
    }
    for (final hotel in hotels) {
      if (hotel.id == id) {
        return hotel;
      }
    }
    return null;
  }

  RoomOffer? get selectedRoom {
    final id = _selectedRoomId;
    if (id == null) {
      return null;
    }
    return roomForId(id);
  }

  List<RoomOffer> get roomsForSelectedHotel => List.unmodifiable(
        rooms
            .where((room) => room.hotelId == _selectedHotelId)
            .toList(growable: false),
      );

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  List<Reservation> get upcomingReservations {
    final today = DateUtils.dateOnly(DateTime.now());
    final items = _reservations
        .where((reservation) =>
            !DateUtils.dateOnly(reservation.checkOut).isBefore(today))
        .toList()
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));
    return List.unmodifiable(items);
  }

  List<Reservation> get pastReservations {
    final today = DateUtils.dateOnly(DateTime.now());
    final items = _reservations
        .where((reservation) =>
            DateUtils.dateOnly(reservation.checkOut).isBefore(today))
        .toList()
      ..sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return List.unmodifiable(items);
  }

  void selectHotel(String hotelId) {
    _selectedHotelId = hotelId;
    final hotelRooms = rooms.where((room) => room.hotelId == hotelId).toList();
    if (hotelRooms.isEmpty) {
      _selectedRoomId = null;
    } else if (!hotelRooms.any((room) => room.id == _selectedRoomId)) {
      _selectedRoomId = hotelRooms.first.id;
    }
    notifyListeners();
  }

  void selectRoom(String roomId) {
    final room = roomForId(roomId);
    if (room == null) {
      return;
    }

    _selectedRoomId = roomId;
    _selectedHotelId = room.hotelId;
    notifyListeners();
  }

  HotelListing hotelForId(String id) {
    return hotels.firstWhere(
      (hotel) => hotel.id == id,
      orElse: () => hotels.first,
    );
  }

  RoomOffer? roomForId(String id) {
    for (final room in rooms) {
      if (room.id == id) {
        return room;
      }
    }
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey) ??
        prefs.getString(_legacyStorageKey) ??
        prefs.getString('reservations');

    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _reservations = decoded
            .whereType<Map>()
            .map((entry) =>
                Reservation.fromJson(Map<String, dynamic>.from(entry)))
            .map(_hydrateLegacyReservation)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (_) {
      _reservations = [];
    }
  }

  Future<void> saveReservation({
    required String guestName,
    required String email,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String specialRequest,
    required List<String> extras,
    required int extrasTotal,
  }) async {
    final hotel = selectedHotel;
    final room = selectedRoom;
    if (hotel == null || room == null) {
      return;
    }

    final reservation = Reservation(
      guestName: guestName,
      email: email,
      hotelId: hotel.id,
      hotelName: hotel.name,
      roomId: room.id,
      roomName: room.name,
      nightlyRate: room.nightlyRate,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      specialRequest: specialRequest,
      extras: extras,
      extrasTotal: extrasTotal,
      createdAt: DateTime.now(),
    );

    _reservations = [reservation, ..._reservations];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_reservations.map((item) => item.toJson()).toList()),
    );
  }

  Reservation _hydrateLegacyReservation(Reservation reservation) {
    final room = roomForId(reservation.roomId);
    if (room == null) {
      return reservation;
    }

    final hotel = hotelForId(room.hotelId);
    return Reservation(
      guestName: reservation.guestName,
      email: reservation.email,
      hotelId: reservation.hotelId.isEmpty ? hotel.id : reservation.hotelId,
      hotelName:
          reservation.hotelName.isEmpty ? hotel.name : reservation.hotelName,
      roomId: reservation.roomId,
      roomName: reservation.roomName,
      nightlyRate: reservation.nightlyRate == 0
          ? room.nightlyRate
          : reservation.nightlyRate,
      checkIn: reservation.checkIn,
      checkOut: reservation.checkOut,
      guests: reservation.guests == 0 ? 1 : reservation.guests,
      specialRequest: reservation.specialRequest,
      extras: reservation.extras,
      extrasTotal: reservation.extrasTotal,
      createdAt: reservation.createdAt,
    );
  }
}
