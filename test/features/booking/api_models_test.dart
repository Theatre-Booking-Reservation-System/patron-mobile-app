import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';

void main() {
  test('maps the current catalogue production contract', () {
    final production = ProductionDto.fromJson({
      'productionId': 'production-id',
      'titleEn': 'English title',
      'titleSi': 'Sinhala title',
      'titleTa': 'Tamil title',
      'language': 'ENGLISH',
      'genre': 'Drama',
      'descriptionEn': 'English description',
      'descriptionSi': 'Sinhala description',
      'descriptionTa': 'Tamil description',
      'baseTicketCost': 1250.0,
      'releaseDate': '2026-10-02',
      'posterImageUrl': 'http://example.com/poster.jpg',
      'status': 1,
    });

    expect(production.id, 'production-id');
    expect(production.language, 'english');
    expect(production.baseTicketCost, 1250);
    expect(production.posterImageUrl, 'http://example.com/poster.jpg');
    expect(production.releaseDate, DateTime(2026, 10, 2));
    expect(production.title['ta'], 'Tamil title');
  });

  test(
    'maps scalar title and description from the live catalogue response',
    () {
      final production = ProductionDto.fromJson({
        'productionId': 'production-id',
        'title': 'Hamlet',
        'description': 'A Shakespearean tragedy.',
        'language': 'ENGLISH',
        'genre': 'Tragedy',
        'baseTicketCost': 2500.0,
        'releaseDate': '2026-10-15',
        'status': 1,
      });

      expect(production.title['en'], 'Hamlet');
      expect(production.synopsis['en'], 'A Shakespearean tragedy.');
    },
  );

  test('combines catalogue performance date and time', () {
    final performance = PerformanceDto.fromJson({
      'performanceId': 'performance-id',
      'productionId': 'production-id',
      'date': '2026-10-09',
      'time': '18:30:00',
      'sessionType': 'EVENING',
      'status': 1,
    });

    expect(performance.dateTime, DateTime(2026, 10, 9, 18, 30));
    expect(performance.session, 'evening');
  });

  test('maps the current seat-service response contract', () {
    final zone = SeatZoneDto.fromJson({
      'zoneId': 'zone-id',
      'section': 'UPPER_CIRCLE',
      'zoneName': 'Centre',
      'matineePct': 100,
      'eveningPct': 120,
    });
    final seat = SeatDto.fromJson({
      'seatId': 'seat-id',
      'zoneId': 'zone-id',
      'section': 'UPPER_CIRCLE',
      'zoneName': 'Centre',
      'rowLabel': 'B',
      'seatNumber': 12,
      'wheelchairSpace': false,
      'status': 'BLOCKED',
    });

    expect(zone.section, 'upperCircle');
    expect(seat.id, 'seat-id');
    expect(seat.bookingSeatId, 'seat-id');
    expect(seat.section, 'upperCircle');
    expect(seat.status, 'unavailable');
  });

  test('maps the current booking creation request contract', () {
    final request = BookingRequestDto(
      patronId: 'patron-id',
      performanceId: 'performance-id',
      seats: const [
        BookingSeatRequestDto(
          seatId: 'seat-id',
          seatReference: 'A1',
          zoneName: 'Premium',
          section: 'STALLS',
        ),
      ],
      ticketType: 'LOYALTY',
      paymentMethod: 'CREDIT_CARD',
      paymentDetails: const PaymentDetailsDto(
        cardNumber: '4111111111111111',
        expiry: '12/30',
        cvv: '123',
        cardHolderName: 'Nimal Perera',
      ),
    ).toJson();

    expect(request['patronId'], 'patron-id');
    expect(request['ticketType'], 'LOYALTY');
    expect(request['paymentMethod'], 'CREDIT_CARD');
    final seat = (request['seats']! as List).single as Map<String, Object?>;
    expect(seat['seatId'], 'seat-id');
    expect(seat['seatRef'], 'A1');
    final payment = request['paymentDetails']! as Map<String, Object?>;
    expect(payment['cardNumber'], '4111111111111111');
  });

  test('maps QR and ticket fields from a successful booking response', () {
    final booking = BookingDto.fromJson({
      'bookingId': '981c8604-d47c-4c17-8c94-5ea56ea2f8da',
      'bookingRef': 'STB-20260927-65044',
      'cardLast4': '1111',
      'createdAt': '2026-09-27T05:07:43.241206569Z',
      'patronId': 'b1e30605-e78a-4e82-ae17-03fcbf76726e',
      'paymentStatus': 'PAID',
      'performanceId': 'ce16dff6-89e1-45e8-a1ac-067ab886d490',
      'productionName': 'Hamlet 3',
      'qrCode': 'data:image/png;base64,aGVsbG8=',
      'seats': [
        {
          'seatId': 'b0000000-0000-0000-0000-000000000721',
          'seatRef': 'A1',
          'section': 'STALLS',
          'zoneName': 'Premium',
        },
      ],
      'status': 'CONFIRMED',
      'ticketType': 'REGULAR',
      'totalLkr': 2700.00,
    });

    expect(booking.qrCode, startsWith('data:image/png;base64,'));
    expect(booking.cardLast4, '1111');
    expect(booking.ticketType, 'REGULAR');
    expect(booking.seats.single.seatReference, 'A1');
    expect(booking.lines, isEmpty);
  });
}
