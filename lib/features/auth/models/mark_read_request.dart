class MarkReadRequest {
  final bool isRead;

  MarkReadRequest({
    required this.isRead,
  });

  Map<String, dynamic> toJson() {
    return {
      'isRead': isRead,
    };
  }
}