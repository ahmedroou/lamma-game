import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../core/app_theme.dart';
import '../core/game_catalog.dart';

/// Equal-width category tiles that leave room for enlarged Arabic text.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.itemBuilder,
    this.maxColumns = 5,
    this.compact = false,
  });

  final List<GameCategory> categories;
  final Widget Function(GameCategory category) itemBuilder;
  final int maxColumns;
  final bool compact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final minimum = (compact ? 104.0 : 146.0) * scale.clamp(1.0, 2.0);
      final columns = ((constraints.maxWidth + 12) / (minimum + 12))
          .floor()
          .clamp(1, maxColumns);
      final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final category in categories)
            SizedBox(width: width, child: itemBuilder(category)),
        ],
      );
    },
  );
}

/// A locally illustrated category with touch, keyboard and pointer feedback.
class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.selected,
    this.remaining,
    this.compact = false,
  });

  final GameCategory category;
  final VoidCallback? onTap;
  final bool? selected;
  final int? remaining;
  final bool compact;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final selected = widget.selected == true;
    final enabled = widget.onTap != null;
    final active = enabled && (_hovered || _focused || _pressed);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final radius = BorderRadius.circular(22);
    final accent = enabled ? category.color : AppColors.muted;
    final size = widget.compact ? 76.0 : 100.0;
    final titleSize = widget.compact ? 13.0 : 16.0;
    final scale = MediaQuery.textScalerOf(context);

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: enabled,
      label: category.title,
      value: widget.remaining == null
          ? null
          : '${widget.remaining} أسئلة متبقية',
      onTap: widget.onTap,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            if (selected || active)
              BoxShadow(
                color: accent.withValues(alpha: active ? .13 : .06),
                blurRadius: active ? 22 : 14,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (value) => setState(() => _hovered = value),
            onFocusChange: (value) => setState(() => _focused = value),
            onHighlightChanged: (value) => setState(() => _pressed = value),
            splashColor: accent.withValues(alpha: .12),
            highlightColor: accent.withValues(alpha: .06),
            borderRadius: radius,
            child: AnimatedContainer(
              duration: duration,
              padding: EdgeInsets.all(widget.compact ? 10 : 14),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  width: 1.5,
                  color: selected || active
                      ? accent
                      : accent.withValues(alpha: enabled ? .20 : .08),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: size + 8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedScale(
                          scale: reduceMotion
                              ? 1
                              : (_pressed ? .94 : (active ? 1.09 : 1)),
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          child: AnimatedRotation(
                            turns: reduceMotion || !active ? 0 : -.015,
                            duration: duration,
                            child: Opacity(
                              opacity: enabled ? 1 : .35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  category.imageAsset,
                                  width: size,
                                  height: size,
                                  cacheWidth: 300,
                                  fit: BoxFit.cover,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.selected != null)
                          PositionedDirectional(
                            top: 0,
                            end: 0,
                            child: AnimatedContainer(
                              duration: duration,
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: selected ? accent : AppColors.background,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? accent : AppColors.border,
                                ),
                              ),
                              child: Icon(
                                selected
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                size: 17,
                                color: selected
                                    ? AppColors.ink
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: scale.scale(titleSize) * 2.8,
                    child: Center(
                      child: Text(
                        category.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: enabled ? AppColors.white : AppColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: titleSize,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  if (widget.remaining case final remaining?) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 5; i++)
                          Container(
                            width: 12,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i < remaining ? accent : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      remaining > 0
                          ? '$remaining / 5 أسئلة متبقية'
                          : 'اكتمل القسم',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'اختيار الأقسام · جوال', group: 'الأقسام', size: Size(390, 844))
@Preview(
  name: 'اختيار الأقسام · شاشة واسعة',
  group: 'الأقسام',
  size: Size(1024, 800),
)
Widget categorySelectionPreview() {
  final selected = gameCategories
      .take(6)
      .map((category) => category.id)
      .toSet();
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: StatefulBuilder(
            builder: (context, update) => CategoryGrid(
              categories: gameCategories,
              itemBuilder: (category) => CategoryCard(
                category: category,
                selected: selected.contains(category.id),
                onTap: () => update(() {
                  if (selected.contains(category.id)) {
                    selected.remove(category.id);
                  } else if (selected.length < 6) {
                    selected.add(category.id);
                  }
                }),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
