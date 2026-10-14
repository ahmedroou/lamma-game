import 'dart:math';
import '../models/hint_access.dart';
import '../models/question.dart';

abstract final class SurpriseCatalog {
  static Map<String, int> get equalWeights =>
      Map.unmodifiable({for (final card in cards) card.id: 1});
  static final cards = List<SurpriseCard>.unmodifiable([
    SurpriseCard(
      id: 'extra_time_30',
      text: 'مهلة إضافية',
      effect: SurpriseEffect.extraTime,
      amount: 30,
      note:
          'تُضاف 30 ثانية تلقائيًا إلى وقت الفريق الأساسي. فرصة المنافس تبقى 7 ثوانٍ.',
    ),
    SurpriseCard(
      id: 'bonus_20',
      text: '20 نقطة إضافية',
      effect: SurpriseEffect.bonusPoints,
      amount: 20,
      note:
          'تُضاف 20 نقطة تلقائيًا إلى رصيد الفريق الأساسي عند كشف هذه الورقة، مرة واحدة.',
    ),
    SurpriseCard(
      id: 'hint_free',
      text: 'كشف التلميح المجاني',
      effect: SurpriseEffect.hint,
      grantsHint: true,
      note: 'يمكن للفريق الأساسي كشف التلميح المساعد لهذا السؤال دون خصم نقاط.',
    ),
    for (final price in [50, 100])
      SurpriseCard(
        id: 'hint_$price',
        text: 'كشف التلميح',
        effect: SurpriseEffect.hint,
        price: price,
        note:
            'اختياري: ادفع $price نقطة من رصيد الفريق الأساسي لكشف التلميح. لا يُخصم شيء قبل الضغط على زر الشراء.',
      ),
    SurpriseCard(
      id: 'double_points',
      text: 'ضعف النقاط',
      effect: SurpriseEffect.doublePoints,
      note:
          'الفريق الأساسي وحده يحصل على ضعف قيمة السؤال عند الإجابة الصحيحة. المنافس يحصل على القيمة المعتادة.',
    ),
    for (final penalty in [50, 100, 200])
      SurpriseCard(
        id: 'failure_$penalty',
        text: 'غرامة $penalty نقطة',
        effect: SurpriseEffect.failurePenalty,
        amount: penalty,
        note:
            'تُخصم $penalty نقطة من الفريق الأساسي إذا لم يقدّم الإجابة الصحيحة، حتى لو أجاب المنافس. تُحسم الغرامة عند اعتماد نتيجة الجولة.',
      ),
    SurpriseCard(
      id: 'options_free',
      text: 'كشف الخيارات المجاني',
      effect: SurpriseEffect.options,
      note:
          'تكشف الخيارات الستة للفريق الأساسي دون خصم نقاط، ويكون أحدها صحيحًا.',
    ),
    SurpriseCard(
      id: 'options_100',
      text: 'كشف الخيارات مقابل 100 نقطة',
      effect: SurpriseEffect.options,
      price: 100,
      maximumQuestionPoints: 200,
      note:
          'اختياري: ادفع 100 نقطة لكشف الخيارات الستة. هذه الورقة تظهر فقط للسؤال ذي القيمة الأصلية 200 نقطة أو أقل.',
    ),
    SurpriseCard(
      id: 'options_200',
      text: 'كشف الخيارات مقابل 200 نقطة',
      effect: SurpriseEffect.options,
      price: 200,
      note:
          'اختياري: ادفع 200 نقطة من رصيد الفريق الأساسي لكشف الخيارات الستة. لا يتم الخصم قبل الشراء.',
    ),
    SurpriseCard(
      id: 'options_quarter',
      text: 'خيارات مقابل ربع النقاط',
      effect: SurpriseEffect.options,
      pointsDivisor: 4,
      note:
          'عند كشف الخيارات الستة تصبح مكافأة الفريق الأساسي ربع نقاط السؤال. مثال: 400 تصبح 100. المنافس يحتفظ بقيمة السؤال المعتادة. تُحذف كسور النقاط إن وُجدت بعد جمع تخفيضات التلميحات مع ربع النقاط.',
    ),
    SurpriseCard(
      id: 'options_four_random',
      text: 'أربعة خيارات عشوائية',
      effect: SurpriseEffect.options,
      optionCount: 4,
      includeCorrect: false,
      note:
          'تكشف أربعة خيارات عشوائية من الستة دون تكلفة. قد تكون الإجابة الصحيحة خارج الخيارات المعروضة؛ يمكنك الإجابة من معرفتك.',
    ),
    SurpriseCard(
      id: 'options_four_correct',
      text: 'أربعة خيارات… الصحيح بينها',
      effect: SurpriseEffect.options,
      optionCount: 4,
      note: 'تكشف أربعة خيارات دون تكلفة، وتتضمن الإجابة الصحيحة بالتأكيد.',
    ),
    SurpriseCard(
      id: 'plank_time',
      text: 'البلانك يحدد الوقت',
      effect: SurpriseEffect.plank,
      price: 100,
      note:
          'يظهر السؤال أثناء بلانك اللاعب الأثقل وزنًا في الفريق، بمراقبة بشرية. توقف التمرين ينهي فرصة الفريق الأساسي. يمكنك الرفض مقابل خصم 100 نقطة واستخدام الوقت العادي؛ هذا الخصم قد يجعل الرصيد سالبًا.',
    ),
    SurpriseCard(
      id: 'wager_self',
      text: 'راهن على إجابتك القادمة',
      effect: SurpriseEffect.selfWager,
      note:
          'اختياري: راهن بجزء من رصيدك المتاح على جولتك القادمة أنت. الإجابة الصحيحة تضيف مقدار الرهان، والإخفاق يخصمه. لا تُخصم النقاط عند التسجيل.',
    ),
    SurpriseCard(
      id: 'wager_opponent',
      text: 'راهن على إخفاق الخصم',
      effect: SurpriseEffect.opponentWager,
      note:
          'اختر خصمًا ومقدار الرهان. إخفاقه في جولته الأساسية القادمة يكسبك المقدار؛ وإجابته الصحيحة تخصمه منك. لا يخص الرهان فرصته في سؤالك الحالي.',
    ),
    for (final role in [
      ('youngest', 'الأصغر عمرًا'),
      ('tallest', 'الأطول'),
      ('shortest', 'الأقصر'),
      ('oldest', 'الأكبر عمرًا'),
      ('middle_age', 'الوسط عمرًا'),
    ])
      SurpriseCard(
        id: 'answerer_${role.$1}',
        text: '${role.$2} وحده يجيب',
        effect: SurpriseEffect.designatedPlayer,
        selectionRule: role.$1,
        note:
            '${role.$2} في الفريق الأساسي هو وحده من يجيب، وبقية فريقه لا تشارك في النقاش. التحديد والمراقبة تتم حضورياً وشفهياً بين المتنافسين دون حاجة لتسجيل الاسم في التطبيق.',
      ),
    SurpriseCard(
      id: 'double_or_lose',
      text: 'دبل أو خسارة كاملة',
      effect: SurpriseEffect.doubleOrLose,
      note:
          'الإجابة الصحيحة للفريق الأساسي تمنحه ضعف قيمة السؤال. إخفاقه يخصم قيمة السؤال كاملة قبل المضاعفة، حتى إذا أجاب الخصم. الخصم يحصل على القيمة المعتادة.',
    ),
    SurpriseCard(
      id: 'opponent_bonus_100',
      text: 'هدية للخصم المتفوّق',
      effect: SurpriseEffect.opponentBonus,
      amount: 100,
      note:
          'إذا أخفق الفريق الأساسي وأجاب فريق آخر صحيحًا في فرصته، يحصل الآخر على 100 نقطة إضافية فوق قيمة السؤال. لا مكافأة عند إخفاق الجميع.',
    ),
    SurpriseCard(
      id: 'no_opponent',
      text: 'لا أحد يجيب بعدك',
      effect: SurpriseEffect.noOpponent,
      note:
          'السؤال للفريق الأساسي وحده؛ إخفاقه أو انتهاء وقته لا يفتح فرصة لأي خصم.',
    ),
    SurpriseCard(
      id: 'total_silence',
      text: 'الصمت التام',
      effect: SurpriseEffect.silence,
      note:
          'لا نقاش ولا تصحيح شفهي: أول إجابة تخرج تُعتمد. يسجلها المراقب مرة واحدة ويحكم على صحتها، ولا يمكن استبدالها بعد التسجيل.',
    ),
    SurpriseCard(
      id: 'opponent_picks_answerer',
      text: 'الخصم يحدد من يجيب',
      effect: SurpriseEffect.opponentDesignates,
      note:
          'الفريق المنافس يحدد شفهياً لاعباً واحداً من فريقكم ليجيب وحده دون نقاش مع فريقه. التحديد والمراقبة تتم حضورياً بينكم دون حاجة لتسجيل الاسم في التطبيق.',
    ),
    SurpriseCard(
      id: 'pick_one_answerer',
      text: 'اختر مجيبًا واحدًا',
      effect: SurpriseEffect.selfDesignates,
      note:
          'اختاروا لاعباً واحداً من فريقكم ليجيب وحده دون مشاركة باقي الفريق. التحديد والمراقبة تتم حضورياً بينكم شفهياً دون حاجة لتسجيل الاسم في التطبيق.',
    ),
    SurpriseCard(
      id: 'half_time',
      text: 'نصف الوقت',
      effect: SurpriseEffect.halfTime,
      note:
          'يُخفض وقت الفريق الأساسي تلقائيًا إلى النصف: 30 تصبح 15 ثانية. فرصة المنافس تبقى 7 ثوانٍ.',
    ),
    SurpriseCard(
      id: 'change_question',
      text: 'غيّر السؤال',
      effect: SurpriseEffect.changeQuestion,
      note:
          'استخدام واحد خلال أول 10 ثوانٍ. يُسحب قسم عشوائي من الأقسام المختارة ثم سؤال متاح فيه؛ وقد تتغير الصعوبة. الوقت المتبقي يستمر، والسؤال القديم يبقى محسوبًا ضمن المعروض.',
    ),
    SurpriseCard(
      id: 'choose_opponent_category',
      text: 'اختر قسم الخصم القادم',
      effect: SurpriseEffect.chooseOpponentCategory,
      note:
          'حدد خصمًا وقسمًا من الأقسام المختارة لجولته الأساسية القادمة. إذا نفد القسم قبل جولته يسقط الإلزام. آخر تعيين للفريق هو المعتمد.',
    ),
    SurpriseCard(
      id: 'ban_player_two_turns',
      text: 'استبعاد لاعب لجولتين',
      effect: SurpriseEffect.banPlayer,
      note:
          'اختر خصمًا ولاعبًا يُمنع من الإجابة والنقاش حتى اكتمال جولتين أساسيتين قادمتين للفريق المستهدف. يسري من السؤال التالي ويشمل فرصه خلالها؛ المراقبة بشرية.',
    ),
    SurpriseCard(
      id: 'lucky_wheel',
      text: 'عجلة الحظ',
      effect: SurpriseEffect.wheelOfFortune,
      note:
          'مغامرة اختيارية لصاحب الدور: لف العجلة لفرصة كسب حتى 600 نقطة، أو المجازفة بخسارة 500 نقطة أو الإفلاس أو تحويل الدور للخصم!',
    ),
  ]);

  static List<SurpriseCard> eligibleFor(Question question) => cards
      .where(
        (card) =>
            (card.maximumQuestionPoints == null ||
                question.points <= card.maximumQuestionPoints!) &&
            (card.effect != SurpriseEffect.hint ||
                !question.isIdentity && question.hint.isNotEmpty) &&
            (card.effect != SurpriseEffect.options ||
                question.options.length == 6 &&
                    (question.subtype != 'number_nearest' ||
                        card.optionCount == 4)),
      )
      .toList();

  /// The caller supplies explicitly configured draw weights.
  static SurpriseCard? draw(
    Question question,
    Map<String, int> weights,
    Random random, {
    bool Function(SurpriseCard)? isAllowed,
  }) {
    final eligible = eligibleFor(question)
        .where(
          (card) =>
              (weights[card.id] ?? 0) > 0 && (isAllowed?.call(card) ?? true),
        )
        .toList();
    final total = eligible.fold(0, (sum, card) => sum + weights[card.id]!);
    if (total == 0) return null;
    var roll = random.nextInt(total);
    for (final card in eligible) {
      roll -= weights[card.id]!;
      if (roll < 0) return card;
    }
    throw StateError('Invalid surprise draw weights.');
  }
}
