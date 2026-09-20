import 'package:flutter/material.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.more)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MoreTile(
            icon: Icons.privacy_tip_outlined,
            title: context.l10n.privacyPolicy,
          ),
          _MoreTile(
            icon: Icons.description_outlined,
            title: context.l10n.terms,
          ),
          _MoreTile(
            icon: Icons.manage_accounts_outlined,
            title: context.l10n.manageData,
          ),
          _MoreTile(icon: Icons.help_outline, title: context.l10n.helpSupport),
          _MoreTile(icon: Icons.info_outline, title: context.l10n.aboutUs),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(context.l10n.prototypeContent),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(context.l10n.prototypeContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      ),
    ),
  );
}
