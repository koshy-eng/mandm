class Quiz {
  final int id;
  final String question;
  final String answers; // comma-separated
  final String correctAnswer;
  final int points;
  final int isFake;
  final String? fakeText;
  final String? fakeImage;
  final int challengeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // 🔒 Local fields for tracking progress
  final int isCompleted;
  final int isUnlocked;
  final int userSelected;

  Quiz({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.points,
    required this.isFake,
    this.fakeText,
    this.fakeImage,
    required this.challengeId,
    this.createdAt,
    this.updatedAt,
    this.isCompleted = 0,
    this.isUnlocked = 0,
    this.userSelected = -1,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    id: json['id'],
    question: json['question'],
    answers: json['answers'],
    correctAnswer: json['correct_answer'],
    points: json['points'],
    isFake: json['is_fake'],
    fakeText: json['fake_text'],
    fakeImage: json['fake_image'],
    challengeId: json['challenge_id'],
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
  );

  factory Quiz.fromMap(Map<String, dynamic> map) => Quiz(
    id: map['id'],
    question: map['question'],
    answers: map['answers'],
    correctAnswer: map['correct_answer'],
    points: map['points'],
    isFake: map['is_fake'],
    fakeText: map['fake_text'],
    fakeImage: map['fake_image'],
    challengeId: map['challenge_id'],
    createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    isCompleted: map['is_completed'] ?? 0,
    isUnlocked: map['is_unlocked'] ?? 0,
    userSelected: map['user_selected'] ?? -1,
  );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'correct_answer': correctAnswer,
      'points': points,
      'is_fake': isFake,
      'fake_text': fakeText,
      'fake_image': fakeImage,
      'challenge_id': challengeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      // local tracking fields
      'is_completed': 0,
      'is_unlocked': 0,
      'user_selected': null,
    };
  }

  Quiz copyWith({
    int? isCompleted,
    int? isUnlocked,
    int? userSelected,
  }) {
    return Quiz(
      id: id,
      question: question,
      answers: answers,
      correctAnswer: correctAnswer,
      points: points,
      isFake: isFake,
      fakeText: fakeText,
      fakeImage: fakeImage,
      challengeId: challengeId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      userSelected: userSelected ?? this.userSelected,
    );
  }

}
