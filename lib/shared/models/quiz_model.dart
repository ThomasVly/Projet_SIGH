class QuizTheme {
  final String id;
  final String name;
  final String description;
  final String color;
  final String icon;

  QuizTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });

  factory QuizTheme.fromMap(Map<String, dynamic> map) {
    return QuizTheme(
      id: map['id'] as String? ?? '',
      name: map['theme'] as String? ?? map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      color: map['color'] as String? ?? '#264777',
      icon: map['icon'] as String? ?? '🎯',
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctAnswer: map['answer'] as int? ?? map['correctAnswer'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
    );
  }
}

class Quiz {
  final String id;
  final String theme;
  final List<QuizQuestion> questions;
  final String color;
  final String icon;

  Quiz({
    required this.id,
    required this.theme,
    required this.questions,
    required this.color,
    this.icon = '🎯', // Icône par défaut
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    List<QuizQuestion> questionsList = [];

    if (map['questions'] != null) {
      final questions = map['questions'] as List;
      questionsList = questions.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>)).toList();
    }

    return Quiz(
      id: map['id'] as String? ?? '',
      theme: map['theme'] as String? ?? '',
      color: (map['themeColor'] as String?) ?? (map['color'] as String?) ?? '#264777',
      icon: map['icon'] as String? ?? '🎯',
      questions: questionsList,
    );
  }
}

