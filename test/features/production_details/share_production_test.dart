import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/production_details/domain/contact_directory.dart';
import 'package:patron_mobile_app/features/production_details/presentation/pages/production_details_page.dart';
import 'package:patron_mobile_app/l10n/app_localizations.dart';

const _production = Production(
  id: 'sk-01',
  title: LocalizedText(en: 'Sanda Katha', si: '', ta: ''),
  synopsis: LocalizedText(en: 'A family drama.', si: '', ta: ''),
  language: ProductionLanguage.sinhala,
  genre: 'Drama',
  baseTicketCost: 4000,
  duration: Duration(hours: 2, minutes: 15),
  performances: [],
  castCrew: [CastMember(role: 'director', name: 'Nadeeka Silva')],
);

void main() {
  testWidgets('asks for contacts access, then shares by message', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = _Directory(
      access: ContactAccess.denied,
      afterRequest: ContactAccess.granted,
    );
    await _pump(tester, directory);

    expect(
      find.descendant(
        of: find.byKey(const Key('productionDetailsCapture')),
        matching: find.byKey(const Key('shareProductionButton')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productionDetailsCapture')),
        matching: find.byTooltip('Back'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productionDetailsCapture')),
        matching: find.byTooltip('Favourite'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('productionDetailsCapture')),
        matching: find.text('Sanda Katha'),
      ),
      findsOneWidget,
    );
    expect(find.text('Cast & crew'), findsOneWidget);
    expect(find.text('Director'), findsOneWidget);
    expect(find.text('Nadeeka Silva'), findsOneWidget);

    await _tapShare(tester);

    expect(directory.requestCount, 1);
    expect(find.text('Share with a contact'), findsOneWidget);
    expect(find.text('Nimal Perera'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('shareContactSearch')),
      'Kamal',
    );
    await tester.pumpAndSettle();

    expect(find.text('Nimal Perera'), findsNothing);
    expect(find.text('Kamal Silva'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('shareContactSearch')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shareContact_nimal')));
    await tester.pumpAndSettle();

    expect(directory.shares, hasLength(1));
    expect(directory.shares.single.channel, ContactShareChannel.sms);
    expect(directory.shares.single.address, '0771234567');
    expect(directory.shares.single.subject, 'Sanda Katha');
    expect(directory.shares.single.image.sublist(0, 8), [
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
    ]);
    expect(find.text('Share with a contact'), findsNothing);
  });

  testWidgets('skips the permission prompt when access is already granted', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = _Directory(access: ContactAccess.granted);
    await _pump(tester, directory);

    await _tapShare(tester);

    expect(directory.requestCount, 0);
    expect(find.text('Share with a contact'), findsOneWidget);
  });

  testWidgets('stays on the production when contacts access is declined', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = _Directory(
      access: ContactAccess.denied,
      afterRequest: ContactAccess.denied,
    );
    await _pump(tester, directory);

    await _tapShare(tester);

    expect(directory.requestCount, 1);
    expect(
      find.text(
        'Allow contacts access to share this production with someone you know.',
      ),
      findsOneWidget,
    );
    expect(find.text('Share with a contact'), findsNothing);
  });

  testWidgets('offers Settings when contacts access can no longer be asked', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = _Directory(access: ContactAccess.permanentlyDenied);
    await _pump(tester, directory);

    await _tapShare(tester);

    expect(directory.requestCount, 0);
    expect(find.text('Open Settings'), findsOneWidget);

    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(directory.settingsCount, 1);
    expect(find.text('Share with a contact'), findsNothing);
  });

  testWidgets('lets the patron choose email when a contact has both', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = _Directory(access: ContactAccess.granted);
    await _pump(tester, directory);

    await _tapShare(tester);
    await tester.tap(find.byKey(const Key('shareContact_both')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send an email'));
    await tester.pumpAndSettle();

    expect(directory.shares.single.channel, ContactShareChannel.email);
    expect(directory.shares.single.address, 'both@example.com');
    expect(directory.shares.single.subject, 'Sanda Katha');
  });
}

Future<void> _tapShare(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('shareProductionButton')));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester, _Directory directory) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider(
        create: (_) => AuthBloc(),
        child: ProductionDetailsPage(
          production: _production,
          contactDirectory: directory,
        ),
      ),
    ),
  );
}

class _Directory implements ContactDirectory {
  _Directory({required this.access, this.afterRequest});

  ContactAccess access;
  final ContactAccess? afterRequest;
  var requestCount = 0;
  var settingsCount = 0;
  final shares = <_Share>[];

  @override
  Future<ContactAccess> currentAccess() async => access;

  @override
  Future<List<ShareContact>> loadContacts() async => const [
    ShareContact(id: 'nimal', name: 'Nimal Perera', phones: ['0771234567']),
    ShareContact(
      id: 'kamal',
      name: 'Kamal Silva',
      emails: ['kamal@example.com'],
    ),
    ShareContact(
      id: 'both',
      name: 'Both Channels',
      phones: ['0710000000'],
      emails: ['both@example.com'],
    ),
  ];

  @override
  Future<void> openSettings() async {
    settingsCount++;
  }

  @override
  Future<ContactAccess> requestAccess() async {
    requestCount++;
    access = afterRequest ?? ContactAccess.denied;
    return access;
  }

  @override
  Future<bool> share({
    required ContactShareChannel channel,
    required String address,
    required String subject,
    required Uint8List image,
  }) async {
    shares.add(
      _Share(
        channel: channel,
        address: address,
        subject: subject,
        image: image,
      ),
    );
    return true;
  }
}

class _Share {
  const _Share({
    required this.channel,
    required this.address,
    required this.subject,
    required this.image,
  });

  final ContactShareChannel channel;
  final String address;
  final String subject;
  final Uint8List image;
}
