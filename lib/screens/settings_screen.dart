import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/value_slider.dart';

/// Settings screen.
///
/// Sections: Daten · Kategorien · Standard-Werte · Über
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Einstellungen', style: AppTextStyles.screenTitle),
              const SizedBox(height: 28),

              // ── Daten ──────────────────────────────────────────────────
              const _SectionHeader('DATEN'),
              const SizedBox(height: 10),
              _SettingsButton(
                label: 'Daten exportieren',
                icon: Icons.download_outlined,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Export wird implementiert…')),
                ),
              ),

              const SizedBox(height: 24),

              // ── Kategorien ────────────────────────────────────────────
              const _SectionHeader('KATEGORIEN'),
              const SizedBox(height: 10),
              _SettingsButton(
                label: 'Kategorien neu wählen',
                icon: Icons.tune_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed('/onboarding'),
              ),

              const SizedBox(height: 24),

              // ── Standard-Werte ────────────────────────────────────────
              const _SectionHeader('STANDARD-WERTE'),
              const SizedBox(height: 10),
              const _DefaultValuesSection(),

              const SizedBox(height: 24),

              // ── Über ──────────────────────────────────────────────────
              const _SectionHeader('ÜBER'),
              const SizedBox(height: 10),
              _InfoCard(
                children: [
                  _InfoRow(label: 'Version', value: '0.2.0'),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'App', value: 'LeichtGesagt'),
                  const SizedBox(height: 8),
                  const Text(
                    'Dein persönliches Sprachtagebuch. '
                    'Sprich deinen Tag – die App trackt ihn.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Default values section ───────────────────────────────────────────────────

class _DefaultValuesSection extends StatelessWidget {
  const _DefaultValuesSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = state.activeCategories;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: categories
            .asMap()
            .entries
            .map((entry) {
          final idx = entry.key;
          final cat = entry.value;
          return Column(
            children: [
              if (idx > 0) const Divider(color: AppColors.border, height: 20),
              ValueSlider(
                category: cat,
                value: cat.defaultValue,
                onChanged: (v) =>
                    context.read<AppState>().setDefaultValue(cat.type, v),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionHeading);
  }
}

class _SettingsButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.buttonSecondary),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: AppColors.textDisabled, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
