enum QuestionPresentationType {
  matching,
  grouping,
  statements,
  sequence,
  comparison,
  symbols,
}

final class QuestionElement {
  const QuestionElement({
    required this.id,
    required this.text,
    this.missing = false,
  });
  final String id, text;
  final bool missing;
  factory QuestionElement.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => !{'id', 'text', 'missing'}.contains(key)) ||
        json['id'] is! String ||
        (json['id'] as String).trim().isEmpty ||
        json['text'] is! String ||
        (json['text'] as String).trim().isEmpty ||
        (json['missing'] != null && json['missing'] is! bool) ||
        (json['missing'] == true && json['text'] != '؟')) {
      throw const FormatException(
        'Invalid question element or exposed missing value.',
      );
    }
    return QuestionElement(
      id: json['id'] as String,
      text: json['text'] as String,
      missing: json['missing'] == true,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    if (missing) 'missing': true,
  };
}

final class QuestionSection {
  QuestionSection({
    required this.id,
    required this.title,
    required Iterable<QuestionElement> items,
  }) : items = List.unmodifiable(items);
  final String id, title;
  final List<QuestionElement> items;
  factory QuestionSection.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => !{'id', 'title', 'items'}.contains(key)) ||
        json['id'] is! String ||
        (json['id'] as String).trim().isEmpty ||
        json['title'] is! String ||
        json['items'] is! List) {
      throw const FormatException('Invalid question section.');
    }
    return QuestionSection(
      id: json['id'] as String,
      title: json['title'] as String,
      items: (json['items'] as List).map(
        (item) =>
            QuestionElement.fromJson(Map<String, dynamic>.from(item as Map)),
      ),
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

final class QuestionPresentation {
  QuestionPresentation({
    required this.type,
    required Iterable<QuestionSection> sections,
  }) : sections = List.unmodifiable(sections);
  final QuestionPresentationType type;
  final List<QuestionSection> sections;
  List<QuestionElement> get elements =>
      sections.expand((section) => section.items).toList();
  factory QuestionPresentation.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => !{'type', 'sections'}.contains(key)) ||
        json['type'] is! String ||
        json['sections'] is! List ||
        !QuestionPresentationType.values.any(
          (type) => type.name == json['type'],
        )) {
      throw const FormatException('Invalid question presentation.');
    }
    final value = QuestionPresentation(
      type: QuestionPresentationType.values.byName(json['type'] as String),
      sections: (json['sections'] as List).map(
        (section) =>
            QuestionSection.fromJson(Map<String, dynamic>.from(section as Map)),
      ),
    );
    value.validate();
    return value;
  }
  void validate() {
    final items = elements;
    if (sections.isEmpty ||
        sections.length > 2 ||
        sections.map((section) => section.id).toSet().length !=
            sections.length ||
        items.map((item) => item.id).toSet().length != items.length ||
        sections.any(
          (section) => section.items.isEmpty || section.items.length > 8,
        )) {
      throw const FormatException(
        'Question sections/items must be distinct and bounded.',
      );
    }
    if (type == QuestionPresentationType.matching) {
      if (sections.length != 2 ||
          sections[0].id != 'left' ||
          sections[1].id != 'right' ||
          sections[0].items.length != sections[1].items.length ||
          sections[0].items.length < 2 ||
          sections[0].items.length > 4) {
        throw const FormatException(
          'Matching requires equally sized left/right sides.',
        );
      }
      return;
    }
    if (sections.length != 1 ||
        switch (type) {
          QuestionPresentationType.grouping => !{6, 8}.contains(items.length),
          QuestionPresentationType.statements => !{4, 5}.contains(items.length),
          QuestionPresentationType.sequence =>
            items.length < 3 ||
                items.length > 8 ||
                !items.any((item) => item.missing),
          QuestionPresentationType.comparison =>
            items.length < 3 || items.length > 6,
          QuestionPresentationType.symbols => items.length > 6,
          QuestionPresentationType.matching => false,
        }) {
      throw const FormatException(
        'Invalid item count for question presentation.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'sections': sections.map((section) => section.toJson()).toList(),
  };
}
