import 'package:flutter/material.dart';
import '../../domain/models/team.dart';

final class ScoreEditResult {
  ScoreEditResult(Map<String, int> scores, this.reason)
    : scores = Map.unmodifiable(scores);
  final Map<String, int> scores;
  final String reason;
}

class EditTeamScoresDialog extends StatefulWidget {
  const EditTeamScoresDialog({super.key, required this.teams});
  final List<TeamState> teams;
  @override
  State<EditTeamScoresDialog> createState() => _EditTeamScoresDialogState();
}

class _EditTeamScoresDialogState extends State<EditTeamScoresDialog> {
  final _form = GlobalKey<FormState>();
  late final _values = {for (final t in widget.teams) t.id: '${t.score}'};
  String _reason = '';
  int? _parse(String text) {
    var value = text.trim().replaceAll('−', '-');
    const arabic = '٠١٢٣٤٥٦٧٨٩', persian = '۰۱۲۳۴۵۶۷۸۹';
    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
    }
    return RegExp(r'^-?\d+$').hasMatch(value) ? int.tryParse(value) : null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('تعديل نقاط الفرق'),
    scrollable: true,
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'للمضيف: أدخل المجموع النهائي لكل فريق. يمكن إدخال نقاط سالبة.',
          ),
          const SizedBox(height: 16),
          for (final team in widget.teams)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                key: ValueKey('host-score-${team.id}'),
                initialValue: '${team.score}',
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                textDirection: TextDirection.ltr,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: team.name,
                  helperText: 'الحالي: ${team.score}',
                  counterText: '',
                ),
                onChanged: (value) => _values[team.id] = value,
                validator: (text) {
                  final score = _parse(text ?? '');
                  return score == null || score.abs() > 999999999
                      ? 'أدخل عددًا صحيحًا بين ‎-999999999 و999999999'
                      : null;
                },
              ),
            ),
          TextFormField(
            key: const ValueKey('score-adjustment-reason'),
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'سبب التعديل (اختياري)',
            ),
            onChanged: (value) => _reason = value.trim(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            ScoreEditResult(
              _values.map((id, value) => MapEntry(id, _parse(value)!)),
              _reason,
            ),
          );
        },
        child: const Text('حفظ النقاط'),
      ),
    ],
  );
}
