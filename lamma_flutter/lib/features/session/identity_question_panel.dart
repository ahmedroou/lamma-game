import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../domain/models/session_state.dart';
import '../../shared/components.dart';
import 'question_points_badge.dart';

class IdentityQuestionPanel extends StatelessWidget {
  const IdentityQuestionPanel({
    super.key,
    required this.state,
    required this.onStart,
    required this.onNext,
  });
  final SessionState state;
  final VoidCallback onStart, onNext;

  @override
  Widget build(BuildContext context) {
    final started = state.revealedCards == 3;
    final question = state.question!;
    final revealed = started ? state.identityCluesRevealed : 0;
    final canReveal =
        state.phase == SessionPhase.cards && state.secondsRemaining > 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.purple.withValues(alpha: .18), AppColors.surface],
        ),
        border: Border.all(color: AppColors.purple.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.person_search_outlined,
            color: AppColors.purple,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'من أنا؟',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'كل تلميح إضافي يخفض النقاط إلى النصف.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              QuestionPointsBadge(
                key: const ValueKey('question-points'),
                points: state.availablePoints,
              ),
              Tag(
                started ? '${state.secondsRemaining} ثانية' : 'جاهزين للتحدّي؟',
                color: AppColors.purple,
                icon: Icons.timer_outlined,
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < 3; i++) ...[
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: Container(
                key: ValueKey('identity-clue-$i'),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: revealed > i
                      ? AppColors.purple.withValues(alpha: .14)
                      : AppColors.background.withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: revealed == i + 1
                        ? AppColors.purple
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(
                          'التلميح ${i + 1}',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${question.pointsForClues(i + 1)} نقطة',
                          style: const TextStyle(color: AppColors.gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (revealed > i)
                      Text(
                        question.clues[i],
                        style: const TextStyle(fontSize: 20, height: 1.6),
                      )
                    else
                      const Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: AppColors.muted,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'لم يُكشف بعد',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!started)
            LammaButton(
              label: 'اكشف التلميح الأول · ${question.points} نقطة',
              onPressed: onStart,
            )
          else if (revealed < 3 && canReveal)
            LammaButton(
              label:
                  'التلميح التالي · ${question.pointsForClues(revealed + 1)} نقطة',
              secondary: true,
              onPressed: onNext,
              icon: Icons.lightbulb_outline,
            ),
        ],
      ),
    );
  }
}
