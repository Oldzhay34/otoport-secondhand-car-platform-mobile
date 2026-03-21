class AdminSpamAttemptActorDto {
  final String actorType;
  final int? actorId;
  final int attempts;

  const AdminSpamAttemptActorDto({
    required this.actorType,
    required this.actorId,
    required this.attempts,
  });

  factory AdminSpamAttemptActorDto.fromJson(Map<String, dynamic> json) {
    return AdminSpamAttemptActorDto(
      actorType: (json['actorType'] ?? '').toString(),
      actorId: (json['actorId'] as num?)?.toInt(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );
  }
}