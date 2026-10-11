import 'dart:typed_data';

enum ContactAccess { granted, denied, permanentlyDenied }

enum ContactShareChannel { sms, email }

class ShareContact {
  const ShareContact({
    required this.id,
    required this.name,
    this.phones = const [],
    this.emails = const [],
  });

  final String id;
  final String name;
  final List<String> phones;
  final List<String> emails;

  bool get canShare => phones.isNotEmpty || emails.isNotEmpty;
}

abstract class ContactDirectory {
  Future<ContactAccess> currentAccess();

  Future<ContactAccess> requestAccess();

  Future<void> openSettings();

  Future<List<ShareContact>> loadContacts();

  Future<bool> share({
    required ContactShareChannel channel,
    required String address,
    required String subject,
    required Uint8List image,
  });
}

String? dialablePhone(String raw) {
  final buffer = StringBuffer();
  final trimmed = raw.trim();
  for (var index = 0; index < trimmed.length; index++) {
    final char = trimmed[index];
    if (char == '+' && buffer.isEmpty) {
      buffer.write(char);
      continue;
    }
    final code = char.codeUnitAt(0);
    if (code >= 48 && code <= 57) buffer.write(char);
  }
  final number = buffer.toString();
  if (number.isEmpty || number == '+') return null;
  return number;
}

Uri? contactShareUri({
  required ContactShareChannel channel,
  required String address,
  required String subject,
  required String body,
}) {
  switch (channel) {
    case ContactShareChannel.sms:
      final phone = dialablePhone(address);
      if (phone == null) return null;
      return Uri(scheme: 'sms', path: phone, queryParameters: {'body': body});
    case ContactShareChannel.email:
      final email = address.trim();
      if (email.isEmpty) return null;
      return Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': subject, 'body': body},
      );
  }
}
