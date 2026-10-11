import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/production_details/domain/contact_directory.dart';
import 'package:patron_mobile_app/features/production_details/presentation/production_share_image.dart';

Future<void> shareProductionWithContact(
  BuildContext context, {
  required Production production,
  required ContactDirectory directory,
  required GlobalKey detailsBoundaryKey,
}) async {
  final image = await captureProductionDetails(detailsBoundaryKey);
  if (!context.mounted) return;
  if (image == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));
    return;
  }
  ContactAccess access;
  try {
    access = await directory.currentAccess();
    if (access != ContactAccess.granted &&
        access != ContactAccess.permanentlyDenied) {
      access = await directory.requestAccess();
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.error)));
    }
    return;
  }
  if (!context.mounted) return;
  if (access == ContactAccess.granted) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => _ShareProductionSheet(
        production: production,
        directory: directory,
        image: image,
      ),
    );
    return;
  }
  if (access == ContactAccess.permanentlyDenied) {
    await _showSettingsDialog(context, directory);
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.contactsPermissionNeeded)),
  );
}

Future<void> _showSettingsDialog(
  BuildContext context,
  ContactDirectory directory,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(dialogContext.l10n.contactsPermissionDenied),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(dialogContext.l10n.notNow),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await directory.openSettings();
          },
          child: Text(dialogContext.l10n.openSettings),
        ),
      ],
    ),
  );
}

class _ShareProductionSheet extends StatefulWidget {
  const _ShareProductionSheet({
    required this.production,
    required this.directory,
    required this.image,
  });

  final Production production;
  final ContactDirectory directory;
  final Uint8List image;

  @override
  State<_ShareProductionSheet> createState() => _ShareProductionSheetState();
}

class _ShareProductionSheetState extends State<_ShareProductionSheet> {
  final _search = TextEditingController();
  var _loading = true;
  var _failed = false;
  List<ShareContact> _contacts = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final contacts = await widget.directory.loadContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final height = (MediaQuery.sizeOf(context).height * .85 - inset)
        .clamp(280.0, MediaQuery.sizeOf(context).height)
        .toDouble();
    final query = _search.text.trim().toLowerCase();
    final visible = [
      for (final contact in _contacts)
        if (_matches(contact, query)) contact,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                context.l10n.shareWithContact,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                key: const Key('shareContactSearch'),
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: context.l10n.searchContacts,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(context, visible)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, List<ShareContact> visible) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.error),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _load,
              child: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      );
    }
    if (visible.isEmpty) {
      return Center(child: Text(context.l10n.noContacts));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = visible[index];
        final name = contact.name.isEmpty
            ? context.l10n.unnamedContact
            : contact.name;
        final detail = [
          if (contact.phones.isNotEmpty) contact.phones.first,
          if (contact.emails.isNotEmpty) contact.emails.first,
        ].join(' · ');
        return ListTile(
          key: Key('shareContact_${contact.id}'),
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(name),
          subtitle: detail.isEmpty ? null : Text(detail),
          onTap: () => _share(contact, name),
        );
      },
    );
  }

  bool _matches(ShareContact contact, String query) {
    if (query.isEmpty) return true;
    final haystack = [
      contact.name,
      ...contact.phones,
      ...contact.emails,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  Future<void> _share(ShareContact contact, String name) async {
    if (!contact.canShare) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.contactHasNoDetails)));
      return;
    }
    final channel = await _chooseChannel(contact, name);
    if (channel == null || !mounted) return;
    final rawAddress = switch (channel) {
      ContactShareChannel.sms => contact.phones.first,
      ContactShareChannel.email => contact.emails.first,
    };
    final address = switch (channel) {
      ContactShareChannel.sms => dialablePhone(rawAddress),
      ContactShareChannel.email => rawAddress.trim(),
    };
    if (address == null || address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));
      return;
    }
    final title = widget.production.title.resolve(
      Localizations.localeOf(context).languageCode,
    );
    final sent = await widget.directory.share(
      channel: channel,
      address: address,
      subject: title,
      image: widget.image,
    );
    if (!mounted) return;
    if (!sent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));
      return;
    }
    Navigator.of(context).pop();
  }

  Future<ContactShareChannel?> _chooseChannel(
    ShareContact contact,
    String name,
  ) async {
    final hasPhone = contact.phones.isNotEmpty;
    final hasEmail = contact.emails.isNotEmpty;
    if (hasPhone && !hasEmail) return ContactShareChannel.sms;
    if (hasEmail && !hasPhone) return ContactShareChannel.email;
    return showDialog<ContactShareChannel>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(name),
        content: Text(
          dialogContext.l10n.shareChooseChannel(
            widget.production.title.resolve(
              Localizations.localeOf(dialogContext).languageCode,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, ContactShareChannel.sms),
            child: Text(dialogContext.l10n.sendMessage),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, ContactShareChannel.email),
            child: Text(dialogContext.l10n.sendEmail),
          ),
        ],
      ),
    );
  }
}
