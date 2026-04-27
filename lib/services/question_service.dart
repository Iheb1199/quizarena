import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';

class QuestionService {
  final _supabase = Supabase.instance.client;

  Future<void> saveQuestion({
    required String sessionId,
    required String text,
    required int orderIndex,
    required List<Map<String, dynamic>> answers,
  }) async {
    final question = await _supabase.from('questions').insert({
      'session_id': sessionId,
      'text': text,
      'order_index': orderIndex,
    }).select().single();

    final questionId = question['id'];

    for (final answer in answers) {
      await _supabase.from('answers').insert({
        'question_id': questionId,
        'text': answer['text'],
        'is_correct': answer['is_correct'],
      });
    }
  }

  Future<List<QuestionModel>> getSessionQuestions(String sessionId) async {
    final data = await _supabase
        .from('questions')
        .select('*, answers(*)')
        .eq('session_id', sessionId)
        .order('order_index', ascending: true)
        .limit(10); // max 10 questions

    return (data as List).map((q) => QuestionModel.fromMap(q)).toList();
  }
}