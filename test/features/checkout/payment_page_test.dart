import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/mock_theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/repositories/mock_theatre_repository.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/payment_page.dart';
import 'package:patron_mobile_app/l10n/app_localizations.dart';

void main() {
  testWidgets('shows card details under the payment options', (tester) async {
    tester.view
      ..physicalSize = const Size(430, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final checkout = CheckoutBloc(
      MockTheatreRepository(MockTheatreApiClient()),
    );
    addTearDown(checkout.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(value: checkout, child: const PaymentPage()),
      ),
    );

    expect(find.text('Card payment'), findsOneWidget);
    expect(find.text('Card details'), findsOneWidget);
    expect(find.byKey(const Key('cardHolderField')), findsOneWidget);
    expect(find.byKey(const Key('cardNumberField')), findsOneWidget);
    expect(find.byKey(const Key('cardExpiryField')), findsOneWidget);
    expect(find.byKey(const Key('cardCvvField')), findsOneWidget);

    await tester.tap(find.text('Pay Now'));
    await tester.pump();

    expect(
      find.text('Enter a card number of 13 to 19 digits.'),
      findsOneWidget,
    );
    expect(find.text('Use MM/YY or MM/YYYY.'), findsOneWidget);
    expect(find.text('Enter a 3 or 4 digit CVV.'), findsOneWidget);
    expect(checkout.state.status, isNot(CheckoutStatus.paying));
  });
}
