import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Screen 1 – Tagesaufnahme
///
/// Layout (top → bottom):
///   Header:   Logo-Icon + App-Name  |  Streak-Badge
///   Prompt:   Kontextueller Hinweistext (Card)
///   Pills:    Aktive Tracking-Kategorien (horizontal scrollbar)
///   Actions:  Standard-Tag-Button | Mic-Button (CTA) | Überspringen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              _Header(),
              const SizedBox(height: AppSpacing.gap),
              _PromptCard(),
              const SizedBox(height: AppSpacing.gap),
              _CategoryPills(),
              const SizedBox(height: 36),
              _ActionArea(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // App icon (inline SVG-derived shape – logo widget)
            _AppIconSmall(),
            const SizedBox(width: 10),
            const Text('LeichtGesagt', style: AppTextStyles.screenTitle),
          ],
        ),
        _StreakBadge(days: 7),
      ],
    );
  }
}

class _AppIconSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(painter: _LogoIconPainter()),
    );
  }
}

/// Paints the LeichtGesagt logo icon:
/// microphone (left) + three ascending bars (right).
class _LogoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 1024; // scale factor from 1024-unit design

    final Paint fill = Paint()
      ..color = AppColors.indigo
      ..style = PaintingStyle.fill;

    final Paint stroke = Paint()
      ..color = AppColors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48 * s
      ..strokeCap = StrokeCap.round;

    // Mic capsule
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(278 * s, 192 * s, 164 * s, 292 * s),
        Radius.circular(82 * s),
      ),
      fill,
    );

    // Mic arch (U-shape)
    final path = Path()
      ..moveTo(218 * s, 375 * s)
      ..cubicTo(218 * s, 602 * s, 504 * s, 602 * s, 504 * s, 375 * s);
    canvas.drawPath(path, stroke);

    // Mic stand
    canvas.drawLine(
      Offset(360 * s, 572 * s),
      Offset(360 * s, 664 * s),
      stroke,
    );

    // Mic base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(276 * s, 646 * s, 168 * s, 40 * s),
        Radius.circular(20 * s),
      ),
      fill,
    );

    // Ascending bars: dim → mid → full opacity
    final bars = [
      (568.0, 486.0, 200.0, 0.38),
      (666.0, 356.0, 330.0, 0.68),
      (764.0, 226.0, 460.0, 1.00),
    ];
    for (final (x, y, h, opacity) in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, 72 * s, h * s),
          Radius.circular(36 * s),
        ),
        Paint()
          ..color = AppColors.indigo.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.indigo.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.indigo.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$days Tage',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contextual Prompt ───────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
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
      child: const Text(
        'Du kannst etwas zu deinem Stresslevel, deiner Ernährung und deinem Energielevel sagen.',
        style: AppTextStyles.body,
      ),
    );
  }
}

// ─── Category Pills ───────────────────────────────────────────────────────────

class _CategoryPills extends StatelessWidget {
  static const _categories = [
    _Category('Stress',    AppColors.stress),
    _Category('Energie',   AppColors.energy),
    _Category('Schlaf',    AppColors.sleep),
    _Category('Ernährung', AppColors.nutrition),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories
            .map((c) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.gapTight),
                  child: _CategoryPill(category: c),
                ))
            .toList(),
      ),
    );
  }
}

class _Category {
  final String name;
  final Color color;
  const _Category(this.name, this.color);
}

class _CategoryPill extends StatelessWidget {
  final _Category category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F3A),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.indigo),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Area ──────────────────────────────────────────────────────────────

class _ActionArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Standard-Tag (secondary)
        _SecondaryButton(
          label: 'Standard-Tag',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.gap),

        // Mic button (primary CTA)
        Center(child: _MicButton(onTap: () {})),
        const SizedBox(height: 6),
        const Center(
          child: Text('Aufnahme starten', style: AppTextStyles.label),
        ),

        const SizedBox(height: AppSpacing.gap),

        // Skip (tertiary, very subtle)
        Center(
          child: GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Heute überspringen',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(label, style: AppTextStyles.buttonSecondary),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MicButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.indigo,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 30),
      ),
    );
  }
}
