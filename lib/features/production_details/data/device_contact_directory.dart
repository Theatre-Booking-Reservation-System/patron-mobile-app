import 'package:flutter/services.dart';
import 'package:patron_mobile_app/features/production_details/domain/contact_directory.dart';

class DeviceContactDirectory implements ContactDirectory {
  const DeviceContactDirectory();

  static const _channel = MethodChannel('patron/contacts');

  @override
  Future<ContactAccess> currentAccess() async {
    final status = await _channel.invokeMethod<String>('status');
    return _access(status);
  }

  @override
  Future<ContactAccess> requestAccess() async {
    final status = await _channel.invokeMethod<String>('request');
    return _access(status);
  }

  @override
  Future<void> openSettings() {
    return _channel.invokeMethod<void>('openSettings');
  }

  @override
  Future<List<ShareContact>> loadContacts() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('load');
    final contacts = <ShareContact>[
      for (final entry in raw ?? const <dynamic>[])
        if (entry is Map)
          ShareContact(
            id: '${entry['id'] ?? ''}',
            name: '${entry['name'] ?? ''}'.trim(),
            phones: [
              for (final phone in entry['phones'] as List<dynamic>? ?? const [])
                if ('$phone'.trim().isNotEmpty) '$phone'.trim(),
            ],
            emails: [
              for (final email in entry['emails'] as List<dynamic>? ?? const [])
                if ('$email'.trim().isNotEmpty) '$email'.trim(),
            ],
          ),
    ];
    contacts.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return contacts;
  }

  @override
  Future<bool> share({
    required ContactShareChannel channel,
    required String address,
    required String subject,
    required Uint8List image,
  }) async {
    if (image.isEmpty || address.trim().isEmpty) return false;
    try {
      final sent = await _channel.invokeMethod<bool>('shareImage', {
        'channel': channel.name,
        'address': address,
        'subject': subject,
        'image': image,
      });
      return sent ?? false;
    } on Object {
      return false;
    }
  }
}

ContactAccess _access(String? status) => switch (status) {
  'granted' => ContactAccess.granted,
  'permanentlyDenied' => ContactAccess.permanentlyDenied,
  _ => ContactAccess.denied,
};
