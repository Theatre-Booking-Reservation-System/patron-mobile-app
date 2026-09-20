import 'dart:async';

import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';

class MockTheatreApiClient implements TheatreApiClient {
  static const _delay = Duration(milliseconds: 280);

  @override
  Future<List<ProductionDto>> getProductions() async {
    await Future<void>.delayed(_delay);
    return _productionJson.map(ProductionDto.fromJson).toList(growable: false);
  }

  @override
  Future<List<SeatDto>> getSeatMap(String performanceId) async {
    await Future<void>.delayed(_delay);
    final result = <SeatDto>[];
    for (final section in const ['stalls', 'circle', 'upperCircle']) {
      final rows = switch (section) {
        'stalls' => const ['AA', 'A', 'P'],
        'circle' => const ['A', 'B', 'D'],
        _ => const ['A', 'B', 'C'],
      };
      for (final row in rows) {
        for (var number = 1; number <= 12; number++) {
          final index = result.length;
          final status = index % 17 == 0
              ? 'booked'
              : index % 23 == 0
              ? 'held'
              : 'available';
          result.add(
            SeatDto.fromJson({
              'id': '$performanceId-$section-$row-$number',
              'section': section,
              'row': row,
              'number': number,
              'status': status,
              'isAccessible': number == 1 && row == rows.last,
            }),
          );
        }
      }
    }
    return result;
  }
}

final List<Map<String, Object?>> _productionJson = [
  {
    'id': 'sanda-katha',
    'title': {'en': 'Sanda Katha', 'si': 'සඳ කතා', 'ta': 'சந்த கதா'},
    'synopsis': {
      'en':
          'A timeless Sinhala drama about family, memory, and the stories that shape us.',
      'si': 'පවුල, මතකය සහ අපව හැඩගස්වන කතා ගැන සිංහල නාට්‍යයකි.',
      'ta':
          'குடும்பம், நினைவு மற்றும் நம்மை வடிவமைக்கும் கதைகள் பற்றிய நாடகம்.',
    },
    'language': 'sinhala',
    'genre': 'Drama',
    'baseTicketCost': 800,
    'posterSeed': 0,
    'performances': [
      {
        'id': 'sk-01',
        'dateTime': '2026-10-09T14:30:00',
        'session': 'matinee',
        'earlyAccessOnly': false,
        'isPoyaDay': false,
      },
      {
        'id': 'sk-02',
        'dateTime': '2026-10-09T18:30:00',
        'session': 'evening',
        'earlyAccessOnly': false,
        'isPoyaDay': false,
      },
    ],
  },
  {
    'id': 'yudham-ondru',
    'title': {
      'en': 'Yudham Ondru',
      'si': 'යුද්ධම් ඔන්ඩ්රු',
      'ta': 'யுத்தம் ஒன்று',
    },
    'synopsis': {
      'en':
          'A compelling Tamil production about courage, loss, and reconciliation.',
      'si': 'ධෛර්යය, අහිමිවීම සහ සංහිඳියාව ගැන දෙමළ නිෂ්පාදනයකි.',
      'ta': 'தைரியம், இழப்பு மற்றும் நல்லிணக்கம் பற்றிய தமிழ் நாடகம்.',
    },
    'language': 'tamil',
    'genre': 'Drama',
    'baseTicketCost': 900,
    'posterSeed': 1,
    'performances': [
      {
        'id': 'yo-01',
        'dateTime': '2026-10-16T15:00:00',
        'session': 'matinee',
        'earlyAccessOnly': false,
        'isPoyaDay': false,
      },
      {
        'id': 'yo-02',
        'dateTime': '2026-10-16T19:00:00',
        'session': 'evening',
        'earlyAccessOnly': true,
        'isPoyaDay': false,
      },
    ],
  },
  {
    'id': 'merchant-venice',
    'title': {
      'en': 'The Merchant of Venice',
      'si': 'වැනීසියේ වෙළෙන්දා',
      'ta': 'வெனிஸ் வணிகன்',
    },
    'synopsis': {
      'en':
          'A new staging of Shakespeare\'s story of justice, mercy, and belonging.',
      'si':
          'යුක්තිය, දයාව සහ අයිතිය ගැන ශේක්ස්පියර්ගේ කතාවේ නව වේදිකාගත කිරීමකි.',
      'ta': 'நீதி, கருணை மற்றும் உரிமை பற்றிய ஷேக்ஸ்பியரின் கதை.',
    },
    'language': 'english',
    'genre': 'Classic',
    'baseTicketCost': 1000,
    'posterSeed': 2,
    'performances': [
      {
        'id': 'mv-01',
        'dateTime': '2026-10-23T18:30:00',
        'session': 'evening',
        'earlyAccessOnly': false,
        'isPoyaDay': false,
      },
      {
        'id': 'mv-poya',
        'dateTime': '2026-10-25T18:30:00',
        'session': 'evening',
        'earlyAccessOnly': false,
        'isPoyaDay': true,
      },
    ],
  },
];
