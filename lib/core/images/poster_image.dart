import 'dart:convert';
import 'dart:typed_data';

final _posterBytes = <String, Uint8List?>{};

/// Decodes a catalogue `posterImageUrl` when it is a `data:image/...;base64,`
/// value. Network URLs return null so the poster can load them with
/// [Image.network].
Uint8List? posterImageBytes(String url) {
  if (_posterBytes.containsKey(url)) return _posterBytes[url];
  final marker = url.indexOf('base64,');
  if (!url.startsWith('data:image') || marker < 0) {
    return _posterBytes[url] = null;
  }
  try {
    final payload = url
        .substring(marker + 'base64,'.length)
        .replaceAll(RegExp(r'\s'), '');
    return _posterBytes[url] = base64Decode(payload);
  } on FormatException {
    return _posterBytes[url] = null;
  }
}
