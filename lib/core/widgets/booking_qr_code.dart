import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class BookingQrCode extends StatelessWidget {
  const BookingQrCode({required this.data, this.size = 180, super.key});

  final String? data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeQrCode(data);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .1),
      ),
      child: bytes == null
          ? Icon(
              Icons.qr_code_2_rounded,
              size: size * .82,
              color: Colors.black87,
            )
          : Image.memory(
              bytes,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              gaplessPlayback: true,
              semanticLabel: 'Booking QR code',
              errorBuilder: (_, _, _) => Icon(
                Icons.qr_code_2_rounded,
                size: size * .82,
                color: Colors.black87,
              ),
            ),
    );
  }
}

Uint8List? _decodeQrCode(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final trimmed = value.trim();
  final payload = trimmed.startsWith('data:')
      ? trimmed.substring(trimmed.indexOf(',') + 1)
      : trimmed;
  try {
    return base64Decode(payload);
  } on FormatException {
    return null;
  }
}
