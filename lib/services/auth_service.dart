import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? avatarUrl,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) return null;

    await _supabase.from('users').insert({
      'id': user.id,
      'display_name': displayName,
      'role': role,
      'avatar_url': avatarUrl,
    });

    // Return null so the app knows to show confirmation message
    // instead of navigating to dashboard
    return null;
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) return null;

    // Check if email is confirmed
    if (user.emailConfirmedAt == null) {
      throw Exception('email_not_confirmed');
    }

    return await getUser(user.id);
  }

  Future<UserModel?> getUser(String uid) async {
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', uid)
        .single();
    return UserModel.fromMap(data);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    if (user.emailConfirmedAt == null) return null;
    return await getUser(user.id);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}