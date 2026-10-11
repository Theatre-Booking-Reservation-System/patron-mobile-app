import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/production_details/domain/contact_directory.dart';
import 'package:patron_mobile_app/features/production_details/domain/production_share_text.dart';

void main() {
  test('builds a production message and a contact address', () {
    expect(
      productionShareText(
        title: 'Sanda Katha',
        venue: 'Sapumal Theatre - Colombo 07',
        synopsis: 'A family drama.',
        details: 'Drama · 2h 15m',
        callToAction: 'Book tickets in the Sapumal Theatre app.',
      ),
      'Sanda Katha\n\n'
      'Sapumal Theatre - Colombo 07\n\n'
      'Drama · 2h 15m\n\n'
      'A family drama.\n\n'
      'Book tickets in the Sapumal Theatre app.',
    );

    expect(dialablePhone('+94 77 123 4567'), '+94771234567');
    expect(dialablePhone('no number'), isNull);

    final sms = contactShareUri(
      channel: ContactShareChannel.sms,
      address: '077 123 4567',
      subject: 'Sanda Katha',
      body: 'A family drama.',
    );
    expect(sms?.scheme, 'sms');
    expect(sms?.path, '0771234567');
    expect(sms?.queryParameters['body'], 'A family drama.');

    final email = contactShareUri(
      channel: ContactShareChannel.email,
      address: 'nimal@example.com',
      subject: 'Sanda Katha',
      body: 'A family drama.',
    );
    expect(email?.scheme, 'mailto');
    expect(email?.path, 'nimal@example.com');
    expect(email?.queryParameters['subject'], 'Sanda Katha');
  });
}
