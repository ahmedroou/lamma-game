import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../domain/models/question_bank_config.dart';

@immutable
class GameCategory {
  const GameCategory(this.id, this.title, this.subtitle, this.icon, this.color);
  final String id, title, subtitle;
  final IconData icon;
  final Color color;
  String get imageAsset => 'assets/category_art/$id.webp';
  bool get usesVectorArt => QuestionBankConfig.newCategoryIds.contains(id);
}

const List<GameCategory> gameCategories = [
  GameCategory(
    'myths',
    'الأساطير والخرافات',
    'حكايات تتجاوز الواقع',
    Icons.auto_awesome,
    AppColors.purple,
  ),
  GameCategory(
    'spacetoon',
    'سبيستون',
    'رحلة إلى كواكب الطفولة',
    Icons.rocket_launch_outlined,
    AppColors.lime,
  ),
  GameCategory(
    'breaking_news',
    'الأخبار العاجلة',
    'وراء كل خبر حكاية',
    Icons.newspaper_outlined,
    AppColors.peach,
  ),
  GameCategory(
    'complete_verse',
    'أكمل الآية',
    'تدبّر وتذكّر',
    Icons.menu_book_rounded,
    AppColors.gold,
  ),
  GameCategory(
    'complete_hadith',
    'أكمل الحديث',
    'من هدي النبوّة',
    Icons.auto_stories_outlined,
    AppColors.lime,
  ),
  GameCategory(
    'how_it_works',
    'كيف تعمل؟',
    'اكتشف سرّ الأشياء',
    Icons.settings_suggest_outlined,
    AppColors.blue,
  ),
  GameCategory(
    'geography',
    'جغرافيا',
    'العالم بين يديك',
    Icons.public_rounded,
    AppColors.blue,
  ),
  GameCategory(
    'maps',
    'خرائط',
    'اقرأ المكان',
    Icons.map_outlined,
    AppColors.purple,
  ),
  GameCategory(
    'flags',
    'أعلام',
    'ألوان تحكي عن البلدان',
    Icons.flag_outlined,
    AppColors.peach,
  ),
  GameCategory(
    'riddles',
    'ألغاز',
    'فكّر خارج المألوف',
    Icons.extension_outlined,
    AppColors.gold,
  ),
  GameCategory(
    'meanings',
    'معاني',
    'وراء الكلمة معنى',
    Icons.translate_rounded,
    AppColors.lime,
  ),
  GameCategory(
    'islamic_history',
    'تاريخ إسلامي',
    'أحداث صنعت التاريخ',
    Icons.account_balance_outlined,
    AppColors.peach,
  ),
  GameCategory(
    'notable_figures',
    'علماء وأعلام',
    'علماء وملوك وأدباء وأكثر',
    Icons.groups_outlined,
    AppColors.blue,
  ),
  GameCategory(
    'who_am_i',
    'من أنا؟',
    'ثلاثة تلميحات… هوية واحدة',
    Icons.person_search_outlined,
    AppColors.purple,
  ),
  GameCategory(
    'symbols_signals',
    'رموز وإشارات',
    'افهم لغة الرموز',
    Icons.traffic_outlined,
    AppColors.blue,
  ),
  GameCategory(
    'abbreviations',
    'اختصارات؟',
    'حروف تحمل معنى',
    Icons.short_text_rounded,
    AppColors.lime,
  ),
  GameCategory(
    'first_last',
    'أول وآخر؟',
    'البدايات والنهايات',
    Icons.first_page_rounded,
    AppColors.peach,
  ),
  GameCategory(
    'split_groups',
    'قسّمهم مجموعتين',
    'اكتشف الرابط الخفي',
    Icons.workspaces_outline,
    AppColors.purple,
  ),
  GameCategory(
    'pair_up',
    'زوجها',
    'كل طرف يبحث عن قرينه',
    Icons.compare_arrows_rounded,
    AppColors.gold,
  ),
  GameCategory(
    'currency_stories',
    'العملة تحكي',
    'قصص النقود ورموزها',
    Icons.payments_outlined,
    AppColors.lime,
  ),
  GameCategory(
    'one_wrong',
    'خطأ واحد فقط',
    'دقّق واكتشف المختلف',
    Icons.fact_check_outlined,
    AppColors.peach,
  ),
  GameCategory(
    'complete_sequence',
    'أكمل السلسلة',
    'اعرف ما قبلها وما بعدها',
    Icons.more_horiz_rounded,
    AppColors.blue,
  ),
  GameCategory(
    'relationship',
    'ما العلاقة؟',
    'عنصران… رابط واحد',
    Icons.hub_outlined,
    AppColors.purple,
  ),
  GameCategory(
    'numbers',
    'أرقام',
    'قدّر وقارن واربط',
    Icons.numbers_rounded,
    AppColors.gold,
  ),
  GameCategory(
    'reverse_question',
    'سؤال عكسي',
    'ما السؤال الذي يُطرح لتكون هذه إجابته؟',
    Icons.sync_alt_rounded,
    AppColors.peach,
  ),
  GameCategory(
    'general_aptitude',
    'قدرات عامة',
    'لفظي وكمي… قس مهاراتك',
    Icons.psychology_rounded,
    AppColors.gold,
  ),
  GameCategory(
    'animal_world',
    'عالم الحيوان',
    'أسرار الكائنات وغرائب البراري',
    Icons.pets_rounded,
    AppColors.lime,
  ),
  GameCategory(
    'guess_food',
    'خمن الأكلة',
    'تذوّق التحدي واكتشف الطبق',
    Icons.restaurant_rounded,
    AppColors.peach,
  ),
];
