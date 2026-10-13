import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../core/app_controller.dart';
import '../../core/app_scope.dart';
import '../../core/game_catalog.dart';
import '../../shared/components.dart';
import '../../shared/category_card.dart';
import '../session/session_setup.dart';
import '../session/session_screen.dart';
import '../session/session_view_model.dart';
import 'card_scene.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppController get _app => AppScope.read(context);
  bool get _motion => _app.settings.motion;
  bool get _haptics => _app.settings.haptics;
  set _motion(bool value) =>
      _app.updateSettings(_app.settings.copyWith(motion: value));
  set _haptics(bool value) =>
      _app.updateSettings(_app.settings.copyWith(haptics: value));
  int _tab = 0;
  void _start([GameCategory? category]) {
    if (_haptics) HapticFeedback.lightImpact();
    openPage<void>(
      context,
      SessionSetup(initialCategory: category),
      animate: _motion,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppScope.watch(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, viewport) {
            final wide = viewport.maxWidth >= 700;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 32 : 22,
                        vertical: viewport.maxHeight < 500 && wide ? 6 : 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.lime,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.ink,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'لَمّة',
                            style: TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          if (wide) ...[
                            const Text(
                              'أسئلة. ضحك. منافسة.',
                              style: TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(width: 20),
                          ],
                          IconButton.filledTonal(
                            tooltip: 'الإعدادات',
                            onPressed: _settings,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.white,
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 21),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        key: PageStorageKey('home-$_tab'),
                        padding: EdgeInsets.fromLTRB(
                          wide ? 32 : 22,
                          6,
                          wide ? 32 : 22,
                          28,
                        ),
                        child: AnimatedSwitcher(
                          duration:
                              _motion &&
                                  !MediaQuery.disableAnimationsOf(context)
                              ? const Duration(milliseconds: 240)
                              : Duration.zero,
                          child: _tab == 0
                              ? _home(
                                  wide,
                                  compact: viewport.maxHeight < 500 && wide,
                                )
                              : _tab == 1
                              ? _categoryPage(wide)
                              : _guide(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) {
              if (_haptics) HapticFeedback.selectionClick();
              setState(() => _tab = value);
            },
            height: 70,
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.lime.withValues(alpha: .13),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.lime),
                label: 'اللمّة',
              ),
              NavigationDestination(
                icon: Icon(Icons.widgets_outlined),
                selectedIcon: Icon(
                  Icons.widgets_rounded,
                  color: AppColors.lime,
                ),
                label: 'الفئات',
              ),
              NavigationDestination(
                icon: Icon(Icons.help_outline_rounded),
                selectedIcon: Icon(Icons.help_rounded, color: AppColors.lime),
                label: 'كيف نلعب؟',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _home(bool wide, {bool compact = false}) => Column(
    key: const ValueKey('home'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!compact)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'هلا باللمّة',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const Tag('GAME NIGHT', color: AppColors.blue),
            ],
          ),
        ),
      if (_app.session != null) ...[_resumeCard(), const SizedBox(height: 18)],
      _hero(wide, compact: compact),
      if (_app.notice != null) ...[const SizedBox(height: 12), _noticeCard()],
      if (_app.saveStatus == LocalSaveStatus.error) ...[
        const SizedBox(height: 12),
        _saveErrorCard(),
      ],
      const SizedBox(height: 22),
      const SectionHeading('اللمّة على نفس الجهاز'),
      const SizedBox(height: 12),
      _mode(
        'جلسة محلية',
        'جهاز واحد · 2–3 فرق · بدون إنترنت',
        Icons.groups_2_outlined,
        AppColors.lime,
        true,
        _start,
      ),
      const SizedBox(height: 20),
      _abilityBanner(),
      const SizedBox(height: 24),
      SectionHeading(
        'لكل شغف، تحدّي',
        action: 'كل الفئات',
        onAction: () => setState(() => _tab = 1),
      ),
      const SizedBox(height: 10),
      _categories(wide, preview: true),
      const SizedBox(height: 22),
      const Center(
        child: Text(
          'اللمة عليكم، والتحدّي علينا',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ),
    ],
  );

  Widget _hero(bool wide, {bool compact = false}) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          const Tag('ستة أقسام… وسابعها مفاجأة', icon: Icons.circle),
          const SizedBox(height: 18),
        ],
        Text(
          'كل جمعة،',
          style: TextStyle(
            fontSize: compact
                ? 30
                : wide
                ? 54
                : 39,
            fontWeight: FontWeight.w700,
            height: 1.18,
            letterSpacing: -.8,
          ),
        ),
        Text(
          'لها تحدّي.',
          style: TextStyle(
            fontSize: compact
                ? 30
                : wide
                ? 54
                : 39,
            fontWeight: FontWeight.w700,
            color: AppColors.lime,
            height: 1.18,
            letterSpacing: -.8,
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        const Text(
          'جمّع أصحابك، جهّز فريقك…\nوخَلّ الكروت تقلب أجواء الجلسة.',
          style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.65),
        ),
        if (wide) ...[
          SizedBox(height: compact ? 12 : 24),
          LammaButton(
            label: 'ابدأ اللمّة',
            icon: Icons.play_arrow_rounded,
            onPressed: _start,
          ),
        ],
      ],
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        compact
            ? 18
            : wide
            ? 30
            : 23,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF292E3B), Color(0xFF1B1C29), Color(0xFF27302A)],
        ),
      ),
      child: wide
          ? Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 28),
                Expanded(
                  child: SizedBox(
                    height: compact ? 175 : 295,
                    child: CardScene(animate: _motion),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                SizedBox(height: 197, child: CardScene(animate: _motion)),
                LammaButton(
                  label: 'ابدأ اللمّة',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _start,
                ),
              ],
            ),
    );
  }

  Widget _mode(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool available,
    VoidCallback onTap,
  ) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: available ? color.withValues(alpha: .35) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 25),
                const Spacer(),
                if (available)
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
                    color: AppColors.muted,
                  )
                else
                  const Tag('قريباً', color: AppColors.purple),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _resumeCard() {
    final model = _app.session!;
    final finished = model.state.phase == SessionPhase.results;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: .08),
        border: Border.all(color: AppColors.blue.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_added_outlined, color: AppColors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  finished ? 'آخر نتيجة محفوظة' : 'لمّتكم محفوظة',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            model.state.teams.map((team) => team.name).join(' • '),
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          Text(
            finished
                ? '${model.state.history.length} جولات مكتملة'
                : 'الجولة ${model.state.turn + 1} · ${model.state.question == null ? 'اختيار القسم' : '${model.state.secondsRemaining} ثانية متبقية'}',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 15),
          LammaButton(
            label: finished ? 'عرض آخر نتيجة' : 'استئناف الجلسة',
            secondary: true,
            icon: finished
                ? Icons.emoji_events_outlined
                : Icons.play_arrow_rounded,
            onPressed: () => openPage<void>(
              context,
              SessionScreen(config: model.config, model: model),
              animate: _motion,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.peach.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppColors.peach),
        const SizedBox(width: 10),
        Expanded(child: Text(_app.notice!)),
        IconButton(
          tooltip: 'إخفاء التنبيه',
          onPressed: _app.dismissNotice,
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
  Widget _saveErrorCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.peach.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تعذّر إكمال الحفظ المحلي',
          style: TextStyle(color: AppColors.peach, fontWeight: FontWeight.w700),
        ),
        const Text('الجلسة موجودة الآن في التطبيق؛ حاول الحفظ قبل إغلاقه.'),
        TextButton(
          onPressed: _app.retrySave,
          child: const Text('إعادة محاولة الحفظ'),
        ),
      ],
    ),
  );

  Widget _abilityBanner() => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: _abilityInfo,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF383025), Color(0xFF242326)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.gold.withValues(alpha: .3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'السابع مو مثل الباقي.',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'قسم القدرات… خذ المخاطرة، وغيّر موازين اللمّة.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Tag(
                    'قدرات جديدة قريباً',
                    color: AppColors.gold,
                    icon: Icons.auto_awesome,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Transform.rotate(
              angle: -.17,
              child: Container(
                width: 62,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: .55),
                  ),
                ),
                child: const Icon(
                  Icons.style_outlined,
                  color: AppColors.gold,
                  size: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _abilityInfo() => _sheet(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.style_outlined, size: 48, color: AppColors.gold),
        const SizedBox(height: 18),
        Text(
          'سؤال، حظ، وورقة تغيّر اللعب',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        const Text(
          'قسم سابع ينضاف تلقائياً لجلستكم. أسئلته من الأقسام الستة اللي اخترتوها. تكسب نقاط السؤال وورقة قدرة، أو تخسر 50 أو 100 أو 150 نقطة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        const DifficultyLegend(),
        const SizedBox(height: 22),
        LammaButton(
          label: 'جهّز جلستك',
          onPressed: () {
            Navigator.pop(context);
            _start();
          },
        ),
      ],
    ),
  );

  Widget _categories(bool wide, {bool preview = false}) => CategoryGrid(
    categories: preview
        ? gameCategories.take(wide ? 6 : 3).toList()
        : gameCategories,
    maxColumns: wide ? 6 : 3,
    compact: true,
    itemBuilder: (category) => CategoryCard(
      category: category,
      compact: true,
      onTap: () => _start(category),
    ),
  );

  Widget _categoryPage(bool wide) => Column(
    key: const ValueKey('categories'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      const Tag('مكتبة البداية', icon: Icons.grid_view_rounded),
      const SizedBox(height: 20),
      Text('وش جوّك اليوم؟', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12),
      const Text(
        'اختار ستة أقسام من مكتبة البداية، وجهّز التحدّي.',
        style: TextStyle(color: AppColors.muted),
      ),
      const SizedBox(height: 28),
      _categories(wide),
      const SizedBox(height: 28),
      const Text(
        'هذه مكتبة تجريبية صغيرة؛ المزيد من الفئات والأسئلة في الطريق.',
        style: TextStyle(color: AppColors.muted),
      ),
    ],
  );

  Widget _guide() => Column(
    key: const ValueKey('guide'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      const Tag('سهلة… وحماسها كبير', icon: Icons.bolt_rounded),
      const SizedBox(height: 20),
      Text(
        '3 كروت.\nوجلسة غير.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 25),
      _step(
        '01',
        'ابدأ بالمفاجأة',
        'اكشف الشرط اللي بيغيّر طريقة إجابتك.',
        Icons.bolt_rounded,
        AppColors.lime,
      ),
      _step(
        '02',
        'اعرف وقتك',
        'اكشف كرت الوقت، واستعد لعدّاد التحدّي.',
        Icons.timer_outlined,
        AppColors.purple,
      ),
      _step(
        '03',
        'السؤال عليكم',
        'اكشف السؤال ليبدأ الوقت. جاوبوا والتزموا بالشرط، ثم اختاروا الفريق الفائز بالنقاط.',
        Icons.psychology_alt_outlined,
        AppColors.blue,
      ),
      _step(
        '05',
        'خمسة أسئلة لكل قسم',
        'اختاروا ستة أقسام، ولكل قسم خمسة أسئلة. نستخدم الجديد أولاً؛ إذا بقي أقل من خمسة نكمل عشوائياً من أسئلة القسم السابقة دون تكرار داخل المباراة. عندما تنتهي الجديدة كلها يمكنك إعادة القسم. استئناف المباراة يتابع السؤال نفسه.',
        Icons.grid_view_rounded,
        AppColors.lime,
      ),
      _step(
        '7ث',
        'فرصة الخصم',
        'بعد انتهاء وقت الفريق تبدأ سبع ثوانٍ للفريق الآخر. مع ثلاثة فرق تُمنح للأقل نقاطاً من الخصمين، وبالقرعة إذا تساويا. يظهر اسم صاحب الفرصة وحده ويبقى الجواب مخفياً حتى نهايتها. إذا كانت الإجابة خاطئة مرّر للخصم قبل كشف الجواب.',
        Icons.timer_outlined,
        AppColors.purple,
      ),
      _step(
        '؟',
        'التلميح يحتاج بطاقة',
        'التلميح المساعد يفتح فقط ببطاقة قدرة أو مفاجأة تمنحه لفريقكم في هذا السؤال. أنواع البطاقات قيد التجهيز. أما تلميحات «من أنا؟» الثلاثة فتتبع آلية القسم الخاصة.',
        Icons.lightbulb_outline_rounded,
        AppColors.gold,
      ),
      _step(
        '؟',
        'تحدّي من أنا؟',
        'اكشف التلميح الأول لكامل النقاط. تحتاج مساعدة؟ التلميح الثاني يبقي نصف النقاط، والثالث يبقي ربعها. قيمة النقاط موضّحة قبل كل كشف.',
        Icons.person_search_outlined,
        AppColors.purple,
      ),
      _step(
        '07',
        'قسم القدرات',
        'سؤال من أقسام جلستكم. نقاطه وورقة قدرة، أو مخاطرة بخسارة 50 أو 100 أو 150 نقطة. أوراقكم تبقى مع فريقكم لتستخدموها في وقتها.',
        Icons.style_outlined,
        AppColors.gold,
      ),
      const SizedBox(height: 12),
      const DifficultyLegend(),
      const SizedBox(height: 20),
      LammaButton(label: 'جاهزين؟ نبدأ', onPressed: _start),
    ],
  );

  Widget _step(
    String number,
    String title,
    String body,
    IconData icon,
    Color color,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(body, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(number, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    ),
  );

  void _sheet(Widget child) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: child,
        ),
      ),
    ),
  );

  void _settings() => _sheet(
    StatefulBuilder(
      builder: (context, updateSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('على مزاجك', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('حركة الكروت'),
            subtitle: const Text('أنيميشن خفيف في الرئيسية'),
            value: _motion,
            onChanged: (value) {
              setState(() => _motion = value);
              updateSheet(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('اهتزاز اللمس'),
            subtitle: const Text('تفاعل لطيف عند اختيار الأزرار'),
            value: _haptics,
            onChanged: (value) {
              setState(() => _haptics = value);
              updateSheet(() {});
            },
          ),
          const Divider(),
          const Text(
            'لَمّة · النسخة الأولى\nتُحفظ الإعدادات تلقائياً على هذا الجهاز.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
