import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';

class LoyaltyPage extends StatelessWidget {
  const LoyaltyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patron = context.watch<AuthBloc>().state.patron;
    final isMember = patron?.isLoyaltyMember == true;
    final cardNumber = patron?.loyaltyCardNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty membership')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2112), Color(0xFF151515)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.gold,
                  size: 38,
                ),
                const SizedBox(height: 22),
                Text(
                  isMember ? 'Sapumal loyalty member' : 'Sapumal loyalty',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isMember
                      ? 'Your membership is active.'
                      : 'Join to unlock member benefits.',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (isMember &&
                    cardNumber != null &&
                    cardNumber.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'CARD  $cardNumber',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Member benefits',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _BenefitTile(
            icon: Icons.local_offer_outlined,
            title: '10% off every ticket',
            description:
                'Your discount is applied after the zone price and any '
                'concession discount are calculated.',
          ),
          const SizedBox(height: 12),
          const _BenefitTile(
            icon: Icons.event_available_outlined,
            title: 'Seven-day early access',
            description:
                'Reserve seats up to seven calendar days before general '
                'booking opens.',
          ),
          if (!isMember) ...[
            const SizedBox(height: 28),
            const FilledButton(
              onPressed: null,
              child: Text('Enroll as a loyalty member'),
            ),
            const SizedBox(height: 8),
            Text(
              'Online enrolment will be available soon.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
