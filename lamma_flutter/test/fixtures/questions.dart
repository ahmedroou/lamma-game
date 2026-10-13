import 'package:lamma/domain/models/question.dart';

const seedQuestions = [
  Question(
    id: 'myths-1',
    categoryId: 'myths',
    text: 'ما أكبر محيط على كوكب الأرض؟',
    answer: 'المحيط الهادئ',
    difficulty: QuestionDifficulty.medium,
  ),
  Question(
    id: 'spacetoon-1',
    categoryId: 'spacetoon',
    text: 'كم لاعباً في فريق كرة القدم داخل الملعب؟',
    answer: '11 لاعباً',
    difficulty: QuestionDifficulty.easy,
  ),
  Question(
    id: 'breaking_news-1',
    categoryId: 'breaking_news',
    text: 'ما اسم الجائزة السينمائية الشهيرة ذات التمثال الذهبي؟',
    answer: 'الأوسكار',
    difficulty: QuestionDifficulty.medium,
  ),
  Question(
    id: 'complete_verse-1',
    categoryId: 'complete_verse',
    text: 'أي كوكب يُعرف بالكوكب الأحمر؟',
    answer: 'المريخ',
    difficulty: QuestionDifficulty.easy,
  ),
  Question(
    id: 'complete_hadith-1',
    categoryId: 'complete_hadith',
    text: 'ما عاصمة اليابان؟',
    answer: 'طوكيو',
    difficulty: QuestionDifficulty.easy,
  ),
  Question(
    id: 'how_it_works-1',
    categoryId: 'how_it_works',
    text: 'من صاحب رواية «البؤساء»؟',
    answer: 'فيكتور هوغو',
    difficulty: QuestionDifficulty.hard,
  ),
  Question(
    id: 'geography-1',
    categoryId: 'geography',
    text: 'ما اسم أول قمر صناعي أُطلق إلى مدار الأرض سنة 1957؟',
    answer: 'سبوتنيك 1',
    difficulty: QuestionDifficulty.hard,
  ),
  Question(
    id: 'maps-1',
    categoryId: 'maps',
    text: 'كم قيمة العدد الثنائي 101101 بالنظام العشري؟',
    answer: '45',
    difficulty: QuestionDifficulty.legendary,
  ),
];

/// Synthetic content is confined to tests; it never ships as authored trivia.
final completeQuestions = [
  ...seedQuestions,
  for (final q in seedQuestions)
    for (var i = 2; i <= 12; i++)
      Question(
        id: '${q.categoryId}-$i',
        categoryId: q.categoryId,
        text: '${q.text} · حالة اختبار $i',
        answer: q.answer,
        difficulty: q.difficulty,
      ),
];
