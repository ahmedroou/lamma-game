import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_scope.dart';
import '../../core/game_catalog.dart';
import '../../domain/models/session_config.dart';
import '../../domain/models/team.dart';
import '../../shared/components.dart';
import '../../shared/category_card.dart';
import 'session_screen.dart';
import 'session_view_model.dart';
import '../../data/repositories/question_repository.dart';
import '../../domain/models/question_usage.dart';
import 'category_replay_options.dart';

class SessionSetup extends StatefulWidget {
  const SessionSetup({super.key, this.initialCategory});
  final GameCategory? initialCategory;
  @override
  State<SessionSetup> createState() => _SessionSetupState();
}

class _SessionSetupState extends State<SessionSetup> {
  final _form = GlobalKey<FormState>();
  final _names = [
    TextEditingController(text: 'الصقور'),
    TextEditingController(text: 'الأبطال'),
    TextEditingController(text: 'العواصف'),
  ];
  int _teamCount = 2;
  bool _starting = false;
  List<String> get _shortages {
    final app = AppScope.maybeWatch(context);
    if (app == null) return const [];
    return _selected.where((id) => !app.canPlayCategory(id)).toList();
  }

  late final Set<String> _selected;
  @override
  void initState() {
    super.initState();
    _selected = gameCategories.take(6).map((category) => category.id).toSet();
    if (widget.initialCategory != null &&
        !_selected.contains(widget.initialCategory!.id)) {
      _selected.remove(_selected.last);
      _selected.add(widget.initialCategory!.id);
    }
  }

  @override
  void dispose() {
    for (final name in _names) {
      name.dispose();
    }
    super.dispose();
  }

  Future<void> _begin() async {
    if (_starting) return;
    if (!_form.currentState!.validate() ||
        _selected.length != GameRules.selectedCategoryCount) {
      return;
    }
    FocusScope.of(context).unfocus();
    final config = SessionConfig(
      teams: [
        for (var i = 0; i < _teamCount; i++)
          TeamState(id: 'team-$i', name: _names[i].text.trim()),
      ],
      categoryIds: _selected,
    );
    final app = AppScope.maybeRead(context);
    if (app?.hasActiveSession == true || app?.unreadableSession == true) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('بدء جلسة جديدة؟'),
          content: Text(
            app!.unreadableSession
                ? 'تعذّر قراءة الجلسة القديمة. بدء جلسة جديدة سيستبدل الحفظ الحالي.'
                : 'لديك جلسة محفوظة. بدء هذه الجلسة سيستبدلها، ولن تتمكن من متابعة القديمة من الرئيسية.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ابدأ جلسة جديدة'),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }
    setState(() => _starting = true);
    try {
      final model = app == null
          ? SessionViewModel(
              config: config,
              questions: LocalQuestionRepository(
                questions: planMatchQuestions(
                  questions: (await LocalQuestionRepository.load())
                      .forCategories(config.categoryIds),
                  categoryIds: config.categoryIds,
                  usage: QuestionUsage(),
                ),
              ),
            )
          : await app.startSession(config);
      if (!mounted) return;
      await openPage<void>(
        context,
        SessionScreen(config: config, model: model),
      );
      if (app == null) model.dispose();
    } on InsufficientQuestions catch (error) {
      if (mounted) {
        final details = error.shortages.entries
            .map(
              (entry) =>
                  '${gameCategories.firstWhere((c) => c.id == entry.key).title}: ${entry.value}/5',
            )
            .join('، ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(
              'القسم يحتاج خمسة أسئلة مختلفة في بنكه وسؤالاً جديداً واحداً على الأقل. $details. أعد القسم المنتهي أو اختر أقساماً أخرى.',
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذّر تحميل أسئلة الأقسام أو حفظ الجلسة. أعد المحاولة؛ الجلسة السابقة لم تُستبدل.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('جهّز اللمّة')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Tag('01 / إعداد الجلسة', icon: Icons.groups_2_outlined),
                  const SizedBox(height: 22),
                  Text(
                    'مين يتحدّى مين؟',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'فريقين أو ثلاثة. ستة أقسام. والقدرات تقلب الموازين.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'الفرق المتنافسة',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 2, label: Text('2')),
                          ButtonSegment(value: 3, label: Text('3')),
                        ],
                        selected: {_teamCount},
                        onSelectionChanged: (selection) =>
                            setState(() => _teamCount = selection.single),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < _teamCount; i++) ...[
                    TextFormField(
                      key: ValueKey('team-name-$i'),
                      controller: _names[i],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'اكتب اسم الفريق';
                        }
                        if (_names
                                .take(_teamCount)
                                .where(
                                  (name) => name.text.trim() == value.trim(),
                                )
                                .length >
                            1) {
                          return 'اختاروا أسماء مختلفة';
                        }
                        return null;
                      },
                      maxLength: 24,
                      textInputAction: i == _teamCount - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: [
                          'الفريق الأول',
                          'الفريق الثاني',
                          'الفريق الثالث',
                        ][i],
                        prefixIcon: Icon(
                          [
                            Icons.bolt_rounded,
                            Icons.auto_awesome,
                            Icons.air_rounded,
                          ][i],
                          color: [
                            AppColors.lime,
                            AppColors.purple,
                            AppColors.blue,
                          ][i],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 16),
                  SectionHeading('اختاروا 6 أقسام · ${_selected.length}/6'),
                  const SizedBox(height: 6),
                  const Text(
                    'بدّلوا الأقسام المختارة لتناسب جوّكم.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  const CategoryReplayOptions(),
                  if (_shortages.isNotEmpty) ...[
                    Container(
                      key: const ValueKey('insufficient-content'),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: .1),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: .4),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'نحتاج خمسة أسئلة مختلفة في بنك القسم. المتاح الجديد: ${_shortages.map((id) => '${gameCategories.firstWhere((c) => c.id == id).title} (${AppScope.read(context).availableQuestionsForCategory(id)})').join('، ')}. أعد القسم إذا انتهى أو اختر قسماً مكتمل المحتوى.',
                        style: const TextStyle(color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  CategoryGrid(
                    categories: gameCategories,
                    itemBuilder: (category) => CategoryCard(
                      key: ValueKey('select-category-${category.id}'),
                      category: category,
                      selected: _selected.contains(category.id),
                      onTap: () {
                        final selected = !_selected.contains(category.id);
                        if (selected &&
                            _selected.length ==
                                GameRules.selectedCategoryCount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ألغِ اختيار قسم أولاً، ثم اختار القسم الجديد.',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          selected
                              ? _selected.add(category.id)
                              : _selected.remove(category.id);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: .12),
                          AppColors.surface,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: .25),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.style_outlined,
                          color: AppColors.gold,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'القسم السابع: القدرات',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'يضاف تلقائياً إلى جلستكم · قدرات جديدة قريباً',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const DifficultyLegend(),
                  const SizedBox(height: 24),
                  LammaButton(
                    key: const ValueKey('start-session'),
                    label: _selected.length == 6
                        ? 'ابدأ التحدّي'
                        : 'باقي ${6 - _selected.length} أقسام',
                    onPressed:
                        _selected.length == 6 &&
                            !_starting &&
                            _shortages.isEmpty
                        ? _begin
                        : null,
                    icon: Icons.play_arrow_rounded,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'نستخدم الأسئلة الجديدة أولاً. إذا بقي أقل من خمسة نكمل الحصة عشوائياً بأسئلة سابقة من القسم، دون تكرار داخل المباراة. إذا انتهت كلها يمكنك إعادة القسم.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
