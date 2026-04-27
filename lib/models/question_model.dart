import 'answer_model.dart';

class QuestionModel {
  final String id;
  final String sessionId;
  final String text;
  final int orderIndex;
  final List<AnswerModel> answers;

  QuestionModel({
    required this.id,
    required this.sessionId,
    required this.text,
    required this.orderIndex,
    this.answers = const [],
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'],
      sessionId: map['session_id'],
      text: map['text'],
      orderIndex: map['order_index'],
      answers: (map['answers'] as List<dynamic>?)
          ?.map((a) => AnswerModel.fromMap(a))
          .toList() ??
          [],
    );
  }
}