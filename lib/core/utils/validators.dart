class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.isEmpty) return 'Display name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  static String? sessionLabel(String? value) {
    if (value == null || value.isEmpty) return 'Session label is required';
    if (value.length < 3) return 'Label must be at least 3 characters';
    return null;
  }

  static String? questionText(String? value) {
    if (value == null || value.isEmpty) return 'Question text is required';
    if (value.length < 5) return 'Question must be at least 5 characters';
    return null;
  }

  static String? answerText(String? value) {
    if (value == null || value.isEmpty) return 'Answer text is required';
    return null;
  }
}