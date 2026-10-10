import 'package:flutter/material.dart';

class HotelListing {
  const HotelListing({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.imagePath,
    required this.rating,
    required this.reviewCount,
    required this.priceFrom,
    required this.description,
    required this.tags,
    required this.accent,
  });

  final String id;
  final String name;
  final String city;
  final String area;
  final String imagePath;
  final double rating;
  final int reviewCount;
  final int priceFrom;
  final String description;
  final List<String> tags;
  final Color accent;
}

class RoomOffer {
  const RoomOffer({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.collection,
    required this.tagline,
    required this.description,
    required this.imagePath,
    required this.nightlyRate,
    required this.maxGuests,
    required this.bedLabel,
    required this.sizeLabel,
    required this.perks,
    required this.accent,
  });

  final String id;
  final String hotelId;
  final String name;
  final String collection;
  final String tagline;
  final String description;
  final String imagePath;
  final int nightlyRate;
  final int maxGuests;
  final String bedLabel;
  final String sizeLabel;
  final List<String> perks;
  final Color accent;
}

class Reservation {
  const Reservation({
    required this.guestName,
    required this.email,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomName,
    required this.nightlyRate,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.specialRequest,
    required this.extras,
    required this.extrasTotal,
    required this.createdAt,
  });

  final String guestName;
  final String email;
  final String hotelId;
  final String hotelName;
  final String roomId;
  final String roomName;
  final int nightlyRate;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String specialRequest;
  final List<String> extras;
  final int extrasTotal;
  final DateTime createdAt;

  int get nights {
    final difference = checkOut.difference(checkIn).inDays;
    return difference > 0 ? difference : 1;
  }

  int get totalPrice => (nightlyRate * nights) + extrasTotal;

  Map<String, dynamic> toJson() {
    return {
      'guestName': guestName,
      'email': email,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomId': roomId,
      'roomName': roomName,
      'nightlyRate': nightlyRate,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guests': guests,
      'specialRequest': specialRequest,
      'extras': extras,
      'extrasTotal': extrasTotal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final legacyRoomName =
        (json['roomName'] ?? json['room'] ?? 'Standart Oda').toString();
    final fallbackCheckIn = DateTime.now();
    final checkIn = _readDate(json['checkIn'], fallbackCheckIn);
    final checkOut = _readDate(
      json['checkOut'],
      fallbackCheckIn.add(const Duration(days: 1)),
    );

    return Reservation(
      guestName: (json['guestName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? 'guest@staybook.demo').toString(),
      hotelId: (json['hotelId'] ?? 'harbor_light').toString(),
      hotelName: (json['hotelName'] ?? json['hotel'] ?? 'Liman Işığı Oteli')
          .toString(),
      roomId: (json['roomId'] ?? _legacyRoomId(legacyRoomName)).toString(),
      roomName: legacyRoomName,
      nightlyRate: _readGuests(json['nightlyRate']),
      checkIn: checkIn,
      checkOut: checkOut,
      guests: _readGuests(json['guests']),
      specialRequest: (json['specialRequest'] ?? '').toString(),
      extras: _readExtras(json['extras']),
      extrasTotal: _readGuests(json['extrasTotal']),
      createdAt: _readDate(json['createdAt'], DateTime.now()),
    );
  }

  static DateTime _readDate(dynamic value, DateTime fallback) {
    if (value is String) {
      return DateTime.tryParse(value) ?? fallback;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return fallback;
  }

  static int _readGuests(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _readExtras(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  static String _legacyRoomId(String roomName) {
    final value = roomName.toLowerCase();
    if (value.contains('suite') || value.contains('süit')) {
      return 'bosphorus_suite';
    }
    if (value.contains('deluxe') || value.contains('delüks')) {
      return 'harbor_deluxe';
    }
    return 'harbor_standard';
  }
}
