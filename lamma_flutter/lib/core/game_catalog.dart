import 'package:flutter/material.dart';
import 'app_theme.dart';

@immutable
class GameCategory {
  const GameCategory(this.id, this.title, this.subtitle, this.icon, this.color);
  final String id, title, subtitle;
  final IconData icon;
  final Color color;
  String get imageAsset => 'assets/category_art/$id.webp';
}

const gameCategories = [
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
];
