class AdminClientStatusUpdateRequest {
  final String? status;
  final List<int>? clientIds;

  const AdminClientStatusUpdateRequest({
    this.status,
    this.clientIds,
  });

  Map<String, dynamic> toJson() {
    return {
      if (status != null && status!.trim().isNotEmpty) 'status': status,
      if (clientIds != null) 'clientIds': clientIds,
    };
  }
}