class AdminWalSearchRequest {
  final int? limit;
  final String? sort;
  final String? actorType;
  final int? actorId;
  final String? method;
  final int? status;
  final String? pathContains;
  final String? q;
  final String? from;
  final String? to;

  const AdminWalSearchRequest({
    this.limit,
    this.sort,
    this.actorType,
    this.actorId,
    this.method,
    this.status,
    this.pathContains,
    this.q,
    this.from,
    this.to,
  });

  Map<String, dynamic> toJson() {
    return {
      if (limit != null) 'limit': limit,
      if (sort != null && sort!.trim().isNotEmpty) 'sort': sort,
      if (actorType != null && actorType!.trim().isNotEmpty)
        'actorType': actorType,
      if (actorId != null) 'actorId': actorId,
      if (method != null && method!.trim().isNotEmpty) 'method': method,
      if (status != null) 'status': status,
      if (pathContains != null && pathContains!.trim().isNotEmpty)
        'pathContains': pathContains,
      if (q != null && q!.trim().isNotEmpty) 'q': q,
      if (from != null && from!.trim().isNotEmpty) 'from': from,
      if (to != null && to!.trim().isNotEmpty) 'to': to,
    };
  }
}