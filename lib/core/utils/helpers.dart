class Helpers {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'finished':
        return 'Finished';
      default:
        return 'Unknown';
    }
  }

  static String rankSuffix(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  static String initialsFromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  static int calculateScore(bool isCorrect, int secondsLeft) {
    if (!isCorrect) return 0;
    // Bonus points for answering quickly
    return 100 + (secondsLeft * 5);
  }
}