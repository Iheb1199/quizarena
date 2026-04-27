class AnswerModel {
  final String id;
  final String questionId;
  final String text;
  final bool isCorrect;

  AnswerModel({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });

  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      id: map['id'],
      questionId: map['question_id'],
      text: map['text'],
      isCorrect: map['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'text': text,
      'is_correct': isCorrect,
    };
  }
}