import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/app_theme.dart';
import '../../core/game_catalog.dart';

/// Offers an explicit new device cycle only after every question was displayed.
class CategoryReplayOptions extends StatefulWidget {
  const CategoryReplayOptions({super.key, this.categoryIds});
  final Set<String>? categoryIds;
  @override
  State<CategoryReplayOptions> createState() => _CategoryReplayOptionsState();
}

class _CategoryReplayOptionsState extends State<CategoryReplayOptions> {
  String? _renewing;
  Future<void> _renew(GameCategory category) async {
    if (_renewing != null) return;
    setState(() => _renewing = category.id);
    try {
      await AppScope.read(context).resetCategory(category.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تمت إعادة قسم ${category.title}. ستُسحب أسئلته عشوائياً من جديد.',
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّرت إعادة القسم. أعد المحاولة بعد نجاح الحفظ.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _renewing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.maybeRead(context);
    if (app == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final exhausted = gameCategories
            .where(
              (c) =>
                  (widget.categoryIds == null ||
                      widget.categoryIds!.contains(c.id)) &&
                  app.isCategoryExhausted(c.id),
            )
            .toList();
        if (exhausted.isEmpty) return const SizedBox.shrink();
        return Container(
          key: const ValueKey('category-replay-options'),
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: .1),
            border: Border.all(color: AppColors.purple.withValues(alpha: .35)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'خلصت أسئلة قسم؟ ابدأ دورة جديدة',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هذه الأقسام ظهرت أسئلتها كلها على الجهاز. أعد القسم ليتاح عشوائياً في المباريات القادمة. تبقى النقاط والأسئلة المعروضة في المباراة الحالية كما هي.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              for (final category in exhausted)
                OutlinedButton.icon(
                  key: ValueKey('renew-category-${category.id}'),
                  onPressed: _renewing == null ? () => _renew(category) : null,
                  icon: Icon(
                    _renewing == category.id
                        ? Icons.hourglass_top_rounded
                        : Icons.refresh_rounded,
                  ),
                  label: Text(
                    _renewing == category.id
                        ? 'نعيد القسم…'
                        : 'إعادة القسم · ${category.title}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
