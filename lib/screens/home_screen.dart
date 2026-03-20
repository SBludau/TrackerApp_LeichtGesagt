import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stt_service.dart';
import '../services/nlp_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/category_pill.dart';
import '../widgets/streak_badge.dart';
import 'review_screen.dart';

/// Screen 1 – Tagesaufnahme (daily voice entry).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final SttService _stt = SttService();
  final NlpService _nlp = NlpService();

  bool _isRecording = false;
  String _liveTranscript = '';

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stt.cancelRecording();
    super.dispose();
  }

  // ─── Recording ───────────────────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _stt.stopRecording();
      return;
    }

    setState(() {
      _isRecording = true;
      _liveTranscript = 'Aufnahme läuft…';
    });

    try {
      final transcript = await _stt.startRecording();
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _liveTranscript = transcript;
      });

      await _navigateToReview(transcript);
    } catch (_) {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _navigateToReview(String transcript) async {
    final state = context.read<AppState>();
    final activeTypes =
        state.activeCategories.map((c) => c.type).toList();
    final result = _nlp.extractValues(transcript, activeTypes);

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          transcript: transcript,
          extractionResult: result,
        ),
      ),
    );
    // Reload after returning from review
    if (mounted) {
      setState(() => _liveTranscript = '');
      await state.loadData();
    }
  }

  // ─── Quick actions ────────────────────────────────────────────────────────────

  Future<void> _standardTag() async {
    final state = context.read<AppState>();
    await state.applyStandardTag();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Standard-Tag gespeichert ✓')),
    );
  }

  Future<void> _skip() async {
    final state = context.read<AppState>();
    await state.skipDay();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tag übersprungen')),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = state.activeCategories;
    final entry = state.todayEntry;
    final hasEntry = state.hasEntryToday;

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
              // ── Header ─────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 34),
                      const SizedBox(width: 10),
                      const Text(
                          'LeichtGesagt', style: AppTextStyles.screenTitle),
                    ],
                  ),
                  StreakBadge(days: state.streak),
                ],
              ),

              const SizedBox(height: 6),

              // ── Date ───────────────────────────────────────────────────────
              Text(
                _todayLabel(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: AppSpacing.gap),

              // ── Context prompt ─────────────────────────────────────────────
              if (!hasEntry) _PromptCard(categories: categories.map((c) => c.name).toList()),

              if (hasEntry)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.insightBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(color: AppColors.insightBorder),
                  ),
                  child: const Text(
                    'Aufnahme für heute bereits gespeichert ✓',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6EE7B7),
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.gap),

              // ── Category pills ─────────────────────────────────────────────
              if (categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories
                        .map((cat) => Padding(
                              padding: const EdgeInsets.only(
                                  right: AppSpacing.gapTight),
                              child: CategoryPill(
                                category: cat,
                                isActive: entry?.values
                                        .containsKey(cat.key) ??
                                    false,
                              ),
                            ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: AppSpacing.gap),

              // ── Live transcript box ────────────────────────────────────────
              if (_isRecording || _liveTranscript.isNotEmpty)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLarge),
                      border: Border.all(
                        color: AppColors.indigo
                            .withValues(alpha: _isRecording ? _pulseAnimation.value : 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: child,
                  ),
                  child: Text(
                    _liveTranscript,
                    style: AppTextStyles.body,
                  ),
                ),

              if (_isRecording || _liveTranscript.isNotEmpty)
                const SizedBox(height: AppSpacing.gap),

              const SizedBox(height: 20),

              // ── Action area ────────────────────────────────────────────────
              _buildActionArea(hasEntry),

              const SizedBox(height: 24),

              // ── Last entry note ────────────────────────────────────────────
              if (state.allEntries.isNotEmpty)
                Center(
                  child: Text(
                    'Letzter Eintrag: ${_lastEntryLabel(state)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea(bool hasEntry) {
    return Column(
      children: [
        // Standard-Tag button
        GestureDetector(
          onTap: hasEntry ? null : _standardTag,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                'Standard-Tag',
                style: TextStyle(
                  fontSize: 14,
                  color: hasEntry
                      ? AppColors.textDisabled
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gap),

        // Mic button
        Center(
          child: GestureDetector(
            onTap: hasEntry ? null : _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: hasEntry
                    ? AppColors.indigo.withValues(alpha: 0.35)
                    : _isRecording
                        ? const Color(0xFFF87171)
                        : AppColors.indigo,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo.withValues(alpha: hasEntry ? 0.1 : 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _isRecording
                ? 'Tippen zum Stoppen'
                : hasEntry
                    ? 'Bereits aufgenommen'
                    : 'Aufnahme starten',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.gap),

        // Skip button
        if (!hasEntry)
          Center(
            child: GestureDetector(
              onTap: _skip,
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

  // ─── Date helpers ─────────────────────────────────────────────────────────────

  String _todayLabel() {
    final now = DateTime.now();
    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag'
    ];
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
    ];
    final wd = weekdays[now.weekday - 1];
    final m = months[now.month - 1];
    return 'Heute, $wd ${now.day}. $m';
  }

  String _lastEntryLabel(AppState state) {
    final entries = state.allEntries
        .where((e) => !e.isSkipped && e.hasValues)
        .toList();
    if (entries.isEmpty) return '—';
    final last = entries.last.date;
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
    ];
    return '${last.day}. ${months[last.month - 1]} ${last.year}';
  }
}

// ─── Prompt Card ──────────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  final List<String> categories;

  const _PromptCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    final names = categories.join(', ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Du kannst etwas zu deinem $names sagen.',
        style: AppTextStyles.body,
      ),
    );
  }
}
