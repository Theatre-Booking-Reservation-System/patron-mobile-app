import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/core/images/poster_image.dart';
import 'package:patron_mobile_app/core/widgets/production_poster.dart';

const _pngDataUri =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

void main() {
  test('decodes a catalogue data-uri poster', () {
    final bytes = posterImageBytes(_pngDataUri);

    expect(bytes, isNotNull);
    expect(bytes, isNotEmpty);
    expect(posterImageBytes(_pngDataUri), same(bytes));
  });

  test('leaves ordinary image URLs for the network loader', () {
    expect(posterImageBytes('https://example.com/poster.jpg'), isNull);
    expect(posterImageBytes('data:image/png;base64,@@@'), isNull);
  });

  testWidgets('paints a data-uri poster from the catalogue', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProductionPoster(
          title: 'Hamlet',
          imageUrl: _pngDataUri,
          showLabel: false,
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
  });
}
